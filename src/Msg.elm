module Msg exposing (Msg(..))

import Form


type Msg
    = FormMsg String Form.Msg
    | NavButtonClicked String
    | SubmitClicked
