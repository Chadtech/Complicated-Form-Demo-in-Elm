# Complicated Form Demo in Elm

This is a complicated form written in Elm.

# Background

Recently I consulted a group of developers that used an out-of-the-box solution for a form and it was leading to some problems for them. Ive seen that situation before. My recommendation was that if they want to scale their form code,or if they are having existing difficulties with it, that they should consider rewrite it from scratch.

# Why

I think that in practice every form is different from every other form. Every different thing about your form has fundamental implications for how your form should be written. Here are some questions that I think matter for the architecture of your form software:

- Are the fields hardcoded or are they dynamic?
- Are some fields optional?
- What does it even mean for a field to be "optional"?
- During form submission, should untouched fields be excluded or should default values be used?
- When should fields be validated? On blur? On key stroke? On navigation? On submission?
- Shoud the form as a whole be validated independently of the fields?
- Are there different sections in the form?
- Do all the fields look the same?
- Do all the fields behave the same?
- Do field values change data type after validation?
- What relationship do the field values have with the data type and structure of the submitted data?

Problems arise with out-of-the-box form packages when they assume things about what a form is supposed to be that vary from what you think the form should be. Furthermore, _you_ might even change your mind at some point, which means you should plan for having to go back and change things. Its much easier to change your own familiar and transparent implementation than to try and cope with an opaque package off the internet.

# So whats this?

This is a form, written in Elm. Its just meant to be an example of a fairly complicated form. While the UI is dead simple, and the form only has 6 fields, Ive intentionally added every bell and whistle to exaggerate its complexity. Heres the spec:

- all the fields are dynamically decoded from json
- all the pages are dynamically decoded from json
- some text fields are required
- some select fields are required
- sometimes one of two fields are required
- fields should validate when the user moves away from them
- some fields need to get validated on every key stroke
- you shouldnt be able to navigate between pages if there are any validation errors on that page
- the form needs to be encodable to json


# Architecture

Each field type is treated as its own little mini-TEA (The Elm Architecture). Each field type lives in a module with its own `view`, `update`, `Model`, and `Msg`. In addition, they all expose a `submit : Model -> Submission Model` function meant to communicate whether its okay to submit this field, and if so provide the field encoded into json.

