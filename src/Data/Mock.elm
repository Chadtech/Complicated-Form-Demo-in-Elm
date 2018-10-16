module Data.Mock exposing
    ( contactInfo
    , forms
    , personalInfo
    )

import Dict exposing (Dict)
import Field exposing (Field)
import Field.Select as Select
import Field.Text as Text
import Form exposing (Form)
import Util exposing (toValidation)


forms : Dict String Form
forms =
    [ ( personalInfo.name, personalInfo )
    , ( contactInfo.name, contactInfo )
    ]
        |> Dict.fromList


personalInfo : Form
personalInfo =
    { label = "Personal Information"
    , name = "personal-information"
    , fields =
        [ ( firstName.name, Field.Text firstName )
        , ( lastName.name, Field.Text lastName )
        , ( gender.name, Field.Select gender )
        ]
            |> Dict.fromList
    , error = Nothing
    , validations = []
    , order = 0
    }


contactInfo : Form
contactInfo =
    { label = "Contact Information"
    , name = "contact-information"
    , fields =
        [ ( phoneNumber.name, Field.Text phoneNumber )
        , ( email.name, Field.Text email )
        , ( contactPreference.name, Field.Select contactPreference )
        ]
            |> Dict.fromList
    , error = Nothing
    , validations =
        [ ( Form.NoMeansOfContact, Form.noMeansOfContact )
            |> toValidation
        ]
    , order = 1
    }


firstName : Text.Model
firstName =
    { value = ""
    , label = "First Name"
    , name = "first-name"
    , validations = []
    , error = Nothing
    , validateOnUpdate = False
    , required = False
    , order = 0
    }


lastName : Text.Model
lastName =
    { value = ""
    , label = "Last Name*"
    , name = "last-name"
    , validations =
        [ ( Text.IsBlank, String.isEmpty ) ]
            |> List.map toValidation
    , error = Nothing
    , validateOnUpdate = False
    , required = True
    , order = 10
    }


phoneNumber : Text.Model
phoneNumber =
    { value = ""
    , label = "Phone Number"
    , name = "phone-number"
    , validations =
        [ ( Text.IsntPhoneNumber, Text.containsLetters ) ]
            |> List.map toValidation
    , error = Nothing
    , validateOnUpdate = True
    , required = False
    , order = 0
    }


email : Text.Model
email =
    { value = ""
    , label = "Email"
    , name = "email"
    , validations =
        [ ( Text.IsntValidEmail, Text.isntValidEmail ) ]
            |> List.map toValidation
    , error = Nothing
    , validateOnUpdate = False
    , required = False
    , order = 10
    }


gender : Select.Model
gender =
    { value = Nothing
    , name = "gender"
    , options = [ "male", "female" ]
    , label = "Gender*"
    , error = Nothing
    , required = True
    , order = 20
    }


contactPreference : Select.Model
contactPreference =
    { value = Nothing
    , name = "preferred-means-of-contact"
    , options = [ "phone", "email" ]
    , label = "Preferred Means of Contact"
    , error = Nothing
    , required = False
    , order = 20
    }
