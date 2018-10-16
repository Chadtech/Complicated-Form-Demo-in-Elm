var app = Elm.Main.init({
    flags: {
        forms: [
            {
                name: "personal-information",
                fields: [
                    {
                        type: "text",
                        name: "first-name",
                        validations: [],
                        required: false
                    },
                    {
                        type: "text",
                        name: "last-name",
                        validations: ["is-blank"],
                        required: true
                    },
                    {
                        type: "select",
                        name: "gender",
                        options: ["male", "female"],
                        required: true
                    }
                ],

            },
            {
                name: "contact-information",
                fields: [
                    {
                        type: "text",
                        name: "phone-number",
                        validations: ["isnt-phone-number"],
                        required: false
                    },
                    {
                        type: "text",
                        name: "email",
                        validations: ["isnt-valid-email"],
                        required: false
                    },
                    {
                        type: "select",
                        name: "preferred-means-of-contact",
                        options: ["phone, email"],
                        required: false
                    }
                ],

            }
        ]
    }
});


