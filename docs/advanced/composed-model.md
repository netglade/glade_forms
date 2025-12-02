---
title: Composed forms
description: Building dynamic lists of forms.
---

Composed forms are ideal when you need to manage multiple instances of the same form. The number of forms doesn’t need to be known upfront — new form instances can be added dynamically at any time.

The core building block of this system is the `ComposedGladeModel`, which maintains and manages the list of all individual `GladeModel` instances contained within the composed form.

ComposedGladeModel is `ChangeNotifier` so all dependant widgets will be rebuilt.

