
# Introduction to the AppKiDo source code

<font color="red">**NOTE! This document is out of date and needs to be cleaned up.**</font>

This is an introduction to the implementation internals of AppKiDo. It's as much for myself as for anyone else interested in diving into the source code.

The classes in AppKiDo mostly fall into Cocoa's Model-View-Controller categories, plus utility classes and some navigation classes that are part view, part model. Since the custom views in AppKiDo are pretty lightweight and straightforward, this document will focus mostly on the model, controller, and navigation classes.


## Model classes: tokens

The fundamental model object in AppKiDo is an AKToken, or simply "token item", or simply "item". AKToken is an abstract base class that represents a Cocoa API construct.  It corresponds to the Token entity in the docset's Core Data store.

Here are the API constructs represented in AppKiDo, and their corresponding item classes:

* **Classes and protocols** -- AKClassToken, AKProtocolToken
* Classes and protocols are collectively referred to as "behaviors". AKClassToken and AKProtocolToken are subclasses of AKBehaviorToken.
* AKBehaviorToken has a third subclass, AKCategoryToken, which is a historical artifact and isn't used in any way the user sees.
* Examples: NSObject, NSTableDataSource.
* **Properties** -- AKPropertyToken
* Many classes have de facto properties in the KVC sense that are not listed as properties in the documentation. AppKiDo doesn't use AKPropertyToken for such properties. Rather, AKMethodToken is used for their documented getter and setter methods.
* Examples: NSDraggingSession's draggingLocation, NSTask's terminationHandler.
* **Methods** -- AKClassMethodToken, AKInstanceMethodToken
* Delegate methods are treated similarly to instance methods, because they are considered part of the behavior of the class. In particular, they are "inherited" by subclasses of the delegating class.
* TODO: Note there are delegate class methods too.
* Notifications are treated similarly to methods, even though they aren't methods at all, for the same reason.
	* TODO: Mention my "pseudo-member" terminology.
* Examples: -init, +stringWithFormat:, tabView:willSelectTabViewItem:, NSWindowWillCloseNotification.
* **Functions** -- AKFunctionToken
* C functions. Also, #define'd macros that look like functions.
* Examples: NSStringFromSelector(), NSAssert1().

xxx discuss AKToken, AKFramework


AppKiDo tags each token item with a **framework name** such as "Foundation" or "AppKit". Generally, each token item belongs to exactly one framework, but there is one exception: AKClassToken. In Cocoa, a class can span multiple frameworks by way of categories. For example, NSString is declared in Foundation but has a category in AppKit. For this reason, AKClassToken can be tagged with multiple framework names, though like every other token item it has exactly one primary owning framework.


## Model class: "the database"

AppKiDo keeps track of all token items using a big singleton object called "the database". Everything AppKiDo displays comes from the database. The result of a database query is zero or more token items. The database is an instance of AKDatabase.

**[TODO: discuss the caching somewhere]**

The database is populated when AppKiDo is launched, and is read-only thereafter. AppKiDo populates the database by parsing two kinds of text files that are installed with Apple's Dev Tools:

* .html files within a docset bundle, and
* .h files within an SDK directory

The locations and internal structure of these files are almost entirely invisible to you as a user.

*[TODO: Discuss how the location of Xcode.app leads to .h files and (sometimes, though moving toward fixed location) docsets.]*

*[TODO: Discuss how the user selects subset of frameworks.]*

Populating the database takes several seconds. One of my long-standing to-do items is to save the parse information using Core Data or sqlite so it doesn't have to be re-derived on every launch and so it doesn't have to live entirely in memory.


## Controllers: ...

xxx only newer controller classes are NSViewController or NSWindowController

xxx special navigation classes AKTopic etc.; kind of model, kind of view (in that they know about presentation)


## Anatomy of the UI

Here are the major areas of an AppKiDo browser window, and the controller classes attached to them.

xxx introduce the term "browser window"

* **Topic browser**
* An NSBrowser for navigating two things: Cocoa's class hierarchy, plus the non-object.
* The first column lists the two root classes in Cocoa: NSObject and NSProxy.
* The first column also lists the names of all the frameworks that have been loaded. For each framework, you can use the topic browser to browse API constructs that are not classes: protocols, functions, and globals.
* Note: when you select a topic in the topic browser, the subordinate items that appear in the next column are NOT called subtopics. The term "subtopic" is used for the subtopic list.
* Each item in the topic browser is called a "**topic**" and is represented by an instance of AKTopic.

* **Subtopic list**
* A single-column table view that lists categories of documentation that are available for the topic that is selected in the topic browser.
* Example: if you select a class in the topic browser, the subtopics include "Class Methods", "Instance Methods", "Delegate Methods", and "Notifications". If you select a framework in the topic browser and then the "Functions" topic for that framework, the subtopics are groups of functions.
* Each item in the topic browser is called a "**subtopic**" and is represented by an instance of AKSubtopic.

* **Doc list**
* A single-column table view that lists documentation items available for the selected subtopic.
* Each item in the doc list is called a "**doc**" and is represented by an instance of AKDoc.

* **Doc view**
* A single-column NSTableView that lists the documentation for whatever item is selected in the doc list.
* or header file

* **Quicklist**
* An NSDrawer that displays "quicklists" and the Search UI.

xxx Topic browser, subtopic list, doc list, and doc view are always in sync. If you select from the Quicklist it navigates all of those panes accordingly in the main window.


## Etc.
----

Debating whether to describe the UI components before the implementation details.  Maybe move UI discussion to a separate doc altogether, and flesh that out with discussion of design decisions (left-right/top-bottom principle, why there are Quicklists, etc.).

* [TODO: this section is a dumping area for things it occurs to me are worth mentioning somewhere]*

"{REMOVE }DEBUGGING", "KLUDGE", etc.

Coding conventions

named things for easy global find-replace, before Xcode had refactoring

mention some classes whose class comments are especially worth reading

the "owning" prefix and the "delegate" suffix

talk about documentation nodes

Where is the right place to mention third-party code?

* [FMDB](https://github.com/ccgus/fmdb) by Gus Mueller
* [TCMXMLWriter](https://github.com/monkeydom/TCMXMLWriter) by Dominik Wagner

*[TODO: Might want to talk about prefixes: AK, AL, DIGS.]*


What happens when you run AppKiDo

* Launch
* Populate a big data structure called "the database". This takes a while, so a splash window is displayed.
* Restore window state that was saved from the previous session.
* Browse
* Let the user navigate the database. The UI provides three ways to do this:
* Search
* Quicklists
* "Just clicking around"
* Quit
* Save window states so they can be restored in the next session.

----

The information displayed in a browser window is hierarchical.

At any given time, exactly one "topic" (also called the "main topic") is
selected. This is the object selected in the "topic browser" at the top of
the window.

"Subtopics" of the selected topic are listed in the "subtopic list" in the
middle left area of the window. If there are any subtopics in the list,
exactly one is selected.

"Docs" that are available for the selected subtopic are listed in the
"doc list" in the middle right area of the window. If there are any docs in
the list, exactly one is selected.

The HTML content of the selected doc is displayed in the "doc view" at the
bottom of the window.

<pre>
		 +-----------------------------------------------------------+
		 |                                                           |
		 |                     Topic Browser                         |
		 |     |                                                     |
		 +-----|----------------------+------------------------------+
		 |     v                      |                              |
		 |   Subtopic  List          --->     Doc List               |
		 |                            |     |                        |
		 +----------------------------+-----|------------------------+
		 |                                  v                        |
		 |                        Doc View                           |
		 |                                                           |
		 +-----------------------------------------------------------+
</pre>


