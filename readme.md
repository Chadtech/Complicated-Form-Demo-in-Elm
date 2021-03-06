# Complicated Form Demo in Elm

This is a complicated form written in Elm. [You can see it live here](http://complicated-form-demo-in-elm.surge.sh/)

# Background

Recently I consulted a company that used an out-of-the-box solution for a form and while it seems to get the job done the code was getting kind of difficult to work with. I proposed that if they plan on scaling their form code, or if its currently leading to problems, that they should consider rewriting it from scratch. This repo is meant to be an example of how it could be done from scratch.

# Why

I think that in practice every form is different from every other form and a lot of these out-of-the-box solutions have implicit assumptions about how your form should be. Its very likely that you will end up fighting with the package you choose. With your own code you can at least make it how you would like in the first place, and when you eventually change your mind about how it should be your own code is transparent enough for you to change it on your own. (then of course, I guess you have to write everything from scratch; how these costs ballance out depends on your project)

# So whats this?

This is a form, written in Elm. Its meant to just stand as an example for how anyone could choose to do a fairly complicated form project. By design the form logic meant to _not_ be abstract and decoupled from the main application architecture. Its meant to be open and refactorable which I think leads to maintainability and scalability.

The UI is dead simple, and the form only has 6 fields, but to make it maximally complicated Ive added every bell and whistle, so hopefully if you want a form with a particular bell or whistle you can see how it could be done in this repo. Heres the spec of the form :

- all the fields are dynamically decoded from json
- all the pages are dynamically decoded from json
- some text fields are required
- some select fields are required
- sometimes one of two fields are required
- some fields should validate when the user moves away from them
- some fields need to get validated on every key stroke
- pages should validate when you try and navigate, and obstruct navigation when they have errors
- the form needs to be encodable to json

# Architecture

Each field type is treated as its own little mini-TEA (The Elm Architecture). Each field type lives in a module with its own `view`, `update`, `Model`, and `Msg`. In addition, they all expose a `submit : Model -> Submission Model` function meant to communicate whether its okay to submit this field, and if so provide the field encoded into json.

If you are familiar with [rtfeldman's spa example](https://github.com/rtfeldman/elm-spa-example/tree/master/src), then you might be familiar with the idea that you could represent your pages as `type Page = Home Home.Model | ..`, where each page has its own module that is its own nested form of TEA. This form example does the same thing with fields: theres a custom type that represents all the varieties of `Field`, pointing to its own module, wherein each one is its own nested form of `TEA`.