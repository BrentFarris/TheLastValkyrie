---
title: Design Patterns
description: Just a list of object oriented design patterns for programming / computer science
tagline: Just a list of object oriented design patterns for programming / computer science
tags: programming, computer science, design patterns, object oriented design patterns, oop design patterns
date: 11/25/2019
---

**JMP**
- [Creational design patterns](#creational-design-patterns)
- [Structural design patterns](#structural-design-patterns)
- [Behavioral design patterns](#behavioral-design-patterns)
- [Further reading](#further-reading)

## Creational design patterns
<a name="abstract-factory">**Abstract factory:**</a> Provide an interface for creating families of related or dependent objects without specifying their concrete classes

<a name="builder">**Builder:**</a> Separate the construction of a complex object from its representation so that the same construction process can create different representations

<a name="factory-method">**Factory Method:**</a> Define an interface for creating an object, but let subclasses decide which class to instantiate. Factory Method lets a class defer instantiation to subclasses

<a name="prototype">**Prototype:**</a> Specify the kinds of objects to create using a prototypical instance, and create new objects by copying this prototype

<a name="singleton">**Singleton:**</a> Ensure a class only has one instance, and provide a global point of access to it

## Structural design patterns
<a name="adapter">**Adapter:**</a> Convert the interface of a class into another interface clients expect. Adapter lets classes work together that couldn't otherwise because of incompatible interfaces

<a name="bridge">**Bridge:**</a> Decouple an abstraction from its implementation so that the two can vary independently

<a name="composite">**Composite:**</a> Compose objects into tree structures to represent part-whole hierarchies. Composite lets clients treat individual objects and compositions of objects uniformly

<a name="decorator">**Decorator:**</a> Attach additional responsibilities to an object dynamically. Decorators provide a flexible alternative to subclassing for extending functionality

<a name="facade">**Façade:**</a> Provide a unified interface to a set of interfaces in a subsystem. Facade defines a higher-level interface that makes the subsystem easier to use

<a name="flyweight">**Flyweight:**</a> Use sharing to support large numbers of fine-graned objects efficiently

<a name="proxy">**Proxy:**</a> Provide a surrogate or placeholder for another object to control access to it

<a name="repository">**Repository:**</a> The abstraction of data storage to allow for multiple different implementations where only one is selected but not known about by the repository user

## Behavioral design patterns
<a name="chain-of-responsibility">**Chain of responsibility:**</a> Avoid coupling the sender of a request to its receiver by giving more than one object a chance to handle the request. Chain the receiving objects and pass the request along the chain until an object handles it

<a name="command">**Command:**</a> Encapsulate a request as an object, thereby letting you parameterize clients with different requests, queue or log requests, and support undo-able operations

<a name="interpreter">**Interpreter:**</a> Given a language, define a representation for its grammar along with an interpreter that uses the representation to interpret sentences in the language

<a name="iterator">**Iterator:**</a> Provide a way to access the elements of an aggregate object sequentially without exposing its underlying representation

<a name="mediator">**Mediator:**</a> Define an object that encapsulates how a set of objects interact. Mediator promotes loose coupling by keeping objects from referring to each other explicitly, and it lets you vary their interaction independently

<a name="memento">**Memento:**</a> Without violating encapsulation, capture and externalize an object's internal state so that the object can be restored to this state later

<a name="observer">**Observer:**</a> Define a one-to-many dependency between objects so that when one object changes state, all its dependents are notified and updated automatically

<a name="state">**State:**</a> Allow an object to alter its behavior when its internal state changes. The object will appear to change its class

<a name="strategy">**Strategy:**</a> Define a family of algorithms, encapsulate each one, and make them interchangeable. Strategy lets the algorithm vary independently from clients that use it

<a name="template-method">**Template method:**</a> Define the skeleton of an algorithm in a operation, deferring some steps to subclasses. Template Method lets subclasses redefine certain steps of an algorithm without changing the algorithm's structure

<a name="visitor">**Visitor:**</a> Represent an operation to be performed on the elements of an object structure. Visitor lets you define a new operation without changing the classes of the elements on which it operates

<a name="unit-of-work">**Unit of work:**</a> This is a class that is responsible for keeping running modifications to commit to a repository in memory. When ready, the unit of work can be committed all in a single transaction. A unit of work can be thought of as a ledger/transaction for work done by a single request

## Further reading
Read more on [wikipedia](https://en.wikipedia.org/wiki/Design_Patterns) or by buying the book by the gang of four [Design Patterns: Elements of Reusable Object-Oriented Software](https://www.amazon.com/Design-Patterns-Elements-Reusable-Object-Oriented/dp/0201633612)
