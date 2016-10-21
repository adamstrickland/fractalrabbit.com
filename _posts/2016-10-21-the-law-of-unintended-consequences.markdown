---
title: The Law of Unintended Consequences
date: 2016-10-21
tags:
  - microservices
  - architecture
  - development
---
# The Law of Unintended Consequences

[John Locke](https://en.wikipedia.org/wiki/John_Locke) was a smart guy. A contemporary of Isaac Newton, among others, he is often thought of as one of the great minds of western philosophy and science. He was the originator of many of the ideas upon which the founding fathers of the United States based their great experiment. And in 1691 he advanced the idea of [unintended consequences](https://www.marxists.org/reference/subject/economics/locke/part1.htm).

We've all heard the phrase, of course. It was popularized in the 1930s by the sociologist Robert K Merton.  Over time, the concept has morphed to refer to the hubris of control, and it is in this sense that most concerns us in the realm of software.  While this hubris - this illusion - is a [demon](https://en.wikipedia.org/wiki/Hubris#/media/File:Paradise_Lost_12.jpg) from which we can never truly be free, there are powerful weapons in our arsenal that we can use, should we have but the [will to do so](https://en.wikipedia.org/wiki/Will_to_power#Kraft_vs._macht).

### Immutability to the Rescue!

Immutability is good, right?  Don't believe me, eh?  You wouldn't be the first (I once had a disagreement with another developer on this point; while he agreed in principle, he felt it didn't apply to Ruby, because functional programming in Ruby is "gross". ¯\\_(ツ)_/¯). Immutable objects are easier to reason about.  Immutable objects tend to drive designs towards smaller, focused data structures and representing change as pipelines of transformations.  And they're less prone to bugs, as maintaining state gets difficult quickly as additional vectors for change are added.

However, there are drawbacks, as well.  They can be less efficient.  And some relationships, such as a bidirectional dependency, can be difficult (but not impossible) to model.  This last often rears its head when we start building data-driven systems: capture data, store it somewhere, spew it back out.  If our data were to be immutable, we'd have to know everything about it before we've created it, and that is often not the case.  However, there is a light at the end of the tunnel.

### Reactive Architecture

[Reactive programming]() is the new hotness in front-end programming, quickly (and with good reason) taking over [web](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0ahUKEwiR87LfqOrPAhVp2oMKHc-QBjEQFggeMAA&url=https%3A%2F%2Ffacebook.github.io%2Freact%2F&usg=AFQjCNHa_1d2VQ9XLEwLkZFQYYmqt39aoQ), [Android](https://github.com/ReactiveX/RxAndroid), [iOS](https://realm.io/news/frp-ios-guide/) and [Netflix](http://techblog.netflix.com/2013/02/rxjava-netflix-api.html) (because we all know that Netflix is the most important thing on the interwebs).  It is rooted in immutability (which is good, right?  __*RIGHT?!?!*__), streams of events and observers of those streams.  And it gives us a paradigm that we can use to safely capture and distribute data in a microservice architecture (as an aside, I really __really__ dislike that term.  It sounds so [Agile](http://dilbert.com/strip/2016-09-19) - in the [enterprisey](https://www.infoq.com/articles/agile-fails-enterprise), not-so-good form *\*shudder\**).

![reactive architecture](/images/reactive_architecture.png)

Above is an example of reactive architecture.  Take some time, read the notes, enjoy yourself.  I would like to call special attention to our protagonist, Geoff, he of the poofy red hair (yes, it really is that poofy).

This design takes a [CQRS](http://martinfowler.com/bliki/CQRS.html) approach, divorcing the structure of the captured data (i.e. the `POST` operation) from the readable, render data (the `GET` operation).  Rather than attempt to use the same underlying, *mutable* storage mechanism, we instead have a stream of events, initiated by the `POST` that results in the distribution of readable data.  The read operation is then very simple: get the things and render them.

Of course, the devil is in the details...  A lot of details, in fact, are hidden under the `Lambda Architecture` component.  What is that, you ask?  For now, check out [the Wikipedia entry](https://en.wikipedia.org/wiki/Lambda_architecture), but for our purposes here we can simply call it a data processing pipeline.

What else?  Oh yeah, the `Writeable DB Entity`.  TBH, I don't love the idea of using an actual database entity here.  I would much prefer a guaranteed message queue.  However, an entity is an entirely viable use for this, as it captures and records the inbound actuals, which create a valid record of transactions that could be recreated if necessary. Also, depending on the maturity of the Lambda Architecture and/or the development team, using a database entity may be a much simpler path to shipping.  And we're all about shipping software, right?  __*RIGHT?!?!*__

--AGTS
