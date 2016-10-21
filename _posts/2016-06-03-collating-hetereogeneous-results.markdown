---
layout: post
title: Collating Hetereogeneous Results
date: 2016-06-03
tags:
  - microservices
  - architecture
  - development
---
## Issue

> You mentioned having each service render search results and then the client (or a median service) would collate those together.   The use case that I see a problem for this is with integrated search (where you have multiple document types) the matching score will not be able to be used to sort them.  This is a scenario where product does NOT want the results sorted by source type (conditions first, doctors second, etc.)  You won't be able to sort by say best match in this case.  If product does not intend to sort this way, then the distributed method is fine, but if they want an integrated result that sorts by best match this method won't work.

## Context

Before we get started, let's make sure we’re all talking about the same things. In the stated issue, the author refers to `search results` and then later to the types `conditions` and `doctors`. In the WellMatch parlance, a _search_ and _search results_ have historically referred to an actual execution of a properly-identified term, be it a provider or a procedure; in other words, the result of a search is specifically __not__ of mixed type. Since we’re talking here about collating/sorting a heterogeneous dataset, I’m going to assume we're actually talking about what (again, in the WM vocabulary) we’ve been calling _typeahead_ (for the record, I prefer iTriage’s use of the word “clinical” here): that is, taking an arbitrary string and resolving it to any number of known domain concepts, the set of which may be of various types and each of which could subsequently be used as a basis for a _search_, as defined above.

## Discussion

Assuming the context as described above is correct, we are looking at something along the lines of

![basic flow](http://yuml.me/diagram/plain/activity/[Client]-typeahead>[API]-get_results>[WellMatchTaxonomy],[API]-get_results>[iTriageClinical])

and the question is: how do we resolve differences in the heterogeneity of the results, as produced by `WellMatchTaxonomy` and `iTriageClinical`? The key here, is the `API` in the middle. 

It’s important to note, however, that this doesn’t specifically mean the `APIGateway`. To be more explicit,  we might find that a structure more like

![likely flow](http://yuml.me/diagram/plain/activity/[Client]-typeahead>[APIGateway]-find>[ClinicalService]-get_results>[WellMatchTaxonomy],[ClinicalService]-get_results>[iTriageClinical])

is better suited to our needs. 

In this scenario, we need a contract between the `Client` and the `APIGateway` that the client can trust. In order to make the client developers’ lives easier (although, honestly, why would we want to do that?), let’s define the structure of that payload to be homogeneous. In other words, each item in the payload returned to the client will have the same schema, regardless of it’s ultimate source. This puts the burden of conforming the results into either the `APIGateway` or the `ClinicalService`. Given here the fact that we have a `ClinicalService` actor, we'll put the functionality there. Implicit in this is that there is now a contract between the `API Gateway` and the `ClinicalService` service, that the results returned by `ClinicalService#find` will be homogeneous; however, the structure defined in that contract may or may not be identical to that in the `Client`/`APIGateway` contract, as different clients may want/need different structures. Hence, we evolve the architecture to something closer to

![bff flow](http://yuml.me/diagram/plain/activity/[iOSClient]-typeahead>[iOSBFF]-find>[ClinicalService],[AndroidClient]-typeahead>[AndroidBFF]-find>[ClinicalService],[WebClient]-typeahead>[WebBFF]-find>[ClinicalService],[ClinicalService]-get_results>[WellMatchTaxonomy],[ClinicalService]-get_results>[iTriageClinical])

Where each [BFF](http://samnewman.io/patterns/architectural/bff/) in turn bears the responsibility for insuring that the results returned to its client adhere to the agreed-upon contract for that client.

All this is well and good, but how does this solve the problem?

In an of itself, this structure does not solve the problem at hand, which is to allow for multiple sorting mechanisms, selected by the client at runtime, that affect the entire dataset.  It does, however, give us an answer as to where that logic should be located, and from there we can derive a solution.

One key here is the fact that the user, via the client, can select the sorting mechanism.  Given the variety of clients, it's safe to assume that not all clients will have identical ideal sort schemes.  For instance, users searching on a mobile device are more likely value geography over other algorithms.  In my opinion, this leads me to infer that the BFF is best-suited to be the final arbiter of what sorting options are returned to its client.  However, for DRY purposes, the `ClinicalService` is likely a better candidate for understanding the dataset as a whole and the relative values.

So what are our options?

Well, for one, we could implement a number of sort-specific endpoints (e.g. `ClinicalService#find-sorted-by-geo`, etc.).  But the approach taken by WellMatch in the past (FWIW, I for one am open to other ideas) has been to allow the client to manage sorting of the results _based on relative values provided by the service_.  Given a standard payload such as

```json
{
  "typeahead": {
    "input": {
      "string": "den",
      "lat": "32.7937137",
      "lng": "-96.7665",
      "radius": 10
    },
    "results": [
      {
        "type": "procedure",
        "value": "Dental Surgery"
      },
      {
        "type": "provider",
        "value": "Arthur Dent"
      }
    ]
  }
}
```

we could easily annotate each result with a set of calculated values


```json
{
  "typeahead": {
    "input": {
      "string": "den",
      "lat": "32.7937137",
      "lng": "-96.7665",
      "radius": 10
    },
    "results": [
      {
        "type": "procedure",
        "value": "Dental Surgery",
        "_meta": {
          "distance": 1.35,
          "relevance": 4.3
        }
      },
      {
        "type": "provider",
        "value": "Arthur Dent",
        "_meta": {
          "distance": 1.75,
          "relevance": 4.5
        }
      }
    ]
  }
}
```

and allow the client to decide which value(s) to use for its own sorting purposes

