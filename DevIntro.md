
# Introduction to the AppKiDo source code

<font color="red">**NOTE! This document is out of date and needs to be cleaned up.**</font>

High-level notes on the implementation internals of AppKiDo.

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
* **Globals**
	* xxx formerly "Types & Constants" -- now lumped with functions -- need to explain what class is used to represent

xxx discuss AKToken, AKFramework


AppKiDo tags each token item with a **framework name** such as "Foundation" or "AppKit". Generally, each token item belongs to exactly one framework, but there is one exception: AKClassToken. In Cocoa, a class can span multiple frameworks by way of categories. For example, NSString is declared in Foundation but has a category in AppKit. For this reason, AKClassToken can be tagged with multiple framework names, though like every other token item it has exactly one primary owning framework.


## Model class: "the database"

AppKiDo keeps track of all token items using a big singleton object called "the database". Everything AppKiDo displays comes from the database. The result of a database query is zero or more token items. The database is an instance of AKDatabase.

**[TODO: discuss the caching somewhere]**

The database is populated when AppKiDo is launched, and is read-only thereafter. AppKiDo populates the database by reading two kinds of files:

- .h files within an SDK directory (found inside the Xcode app bundle)
- the Core Data store inside a docset (Xcode used to require a separate download to install the docset in ~Library/Developer/Shared/Documentation/DocSets)

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


## What happens when you run AppKiDo

Debating whether to describe the UI components before the implementation details.  Maybe move UI discussion to a separate doc altogether, and flesh that out with discussion of design decisions (left-right/top-bottom principle, why there are Quicklists, etc.).

* [TODO: this section is a dumping area for things it occurs to me are worth mentioning somewhere]*

- You launch the app.
- The app populates a big data structure called "the database". This can take a few seconds.
- The app restores any windows that were open when you last quit.
- You browse the contents of the database. The UI provides three ways to do this:
	- Search.
	- Quicklists.
	- "Just clicking around".
- You tell the app to quit.
- Just before quitting, the app saves window states so they can be restored the next time you run it.


## UI Overview

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

```text
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
```


## Overhaul started in 2016

Started an overhaul in 2016.  It was in progress when Xcode 8 came out that year, with completely different docset format.  It was too much work to try to make AppKiDo compatible, if that was even possible.  Also Swift had been around since 2014 and this complicated things.  So now the code is in a broken, unmaintained state.  Now and then I fiddle with the code.  It still runs, I just have to point it at Xcode 7's documentation.

Things that are different in this overhaul:

- No longer parsing HTML files into chunks.  Made launch too time-consuming, especially since I was not saving the results, I was re-parsing from scratch every time.  Also, Apple would make slight changes now and then to the HTML structure and I'd have to tweak to stay compatible.  So now I'm displaying the entire HTML file, scrolled to the anchor for the selected API symbol.
- Am using Core Data to read the docset index instead of FMDB to read the SQLite files.  I imported the mom file from a docset (I don't know which version), which gave me a model file (see [Ole Begemann's blog](https://oleb.net/2018/photos-data-model/) for how to do this), and I hand-tweaked the diagram to make it readable.  Note it is missing inverse relationships, which causes compiler warnings.
- BROKEN: I have to add back the "ALL" options in the subtopic list.
- BROKEN: There is a way to specify which frameworks to include in the database, but it's not working -- *all* frameworks are always included.


## Stuff yet to be organized

DOC: Debating whether to describe the UI components before the implementation details.  Maybe move UI discussion to a separate doc altogether, and flesh that out with discussion of design decisions (left-right/top-bottom principle, why there are Quicklists, etc.).

TODO: Make AKPrefPanelController an NSWindowController, just for completeness.

FEATURE: menu/keyboard for deleting a Favorite

TODO: Rename AKToken, it collides with an Apple class of the same name, hence:
> objc[11198]: Class AKToken is implemented in both ?? (0x1f235b748) and /Users/alee/Library/Developer/Xcode/DerivedData/AppKiDo-bmuozhghnmdyqkeaxqgexpruepoz/Build/Products/Debug/AppKiDo.app/Contents/MacOS/AppKiDo (0x1000deac0). One of the two will be used. Which one is undefined.

FEATURE: multiple selection of Favorites, for drag-drop convenience

TODO: (maybe) real-time update of the display when frameworks are selected/deselected for inclusion; maybe put the frameworks list more front-and-center instead of having to navigate to a tab in the prefs window

BUG: Initial window for selecting Xcode location is not closing on OK, and Cancel doesn't seem to work.

BUG: Do something about all those classes that are mis-perceived as root classes, they're screwing up the first column.  Maybe hard-code NSObject and NSProxy as the only real root classes, and ignore classes whose superclasses can't be found -- looks like it's because I'm not coming across a .h file for them.

TODO: mention use of MOGenerator -- occurs to me I should add it to the Credits too

TODO: maybe use github bug database

TODO: maybe use github wiki -- drawback is that editing local files is so much easier

FEATURE: maybe remove XML export -- no point keeping around code for a feature that won't be used

DOC: instructions for making AppKiDo work (needs docset -- where can people get it? do I want to host a file that size?)

DOC: add per-directory README files, been wanting to do this for ages

"{REMOVE }DEBUGGING", "KLUDGE", etc.

DOC: maybe describe my coding conventions?

the "owning" prefix and the "delegate" suffix

talk about documentation nodes

*[TODO: Might want to talk about prefixes: AK, AL, DIGS.]*


