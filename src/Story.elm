module Story exposing (..)

import Http exposing (Error)
import Task exposing (Task)
import Time

import HN exposing (..)

{-| A HN Item where the kind is "story", and ranked. -}
type alias Story =
    { item : HN.Item
    , rank : Float
    }

{-| A filtered list of HN Items that are ranked by time. -}
stories : Int -> Time.Time -> Task Error (List Int) -> Task Error (List Story)
stories n time ids =
    Task.map (List.filterMap (story time)) (HN.items n ids)

{-| Filters stories from a list of HN Items and ranks them. -}
filterStories : Time.Time -> List HN.Item -> List Story
filterStories time items =
    List.filterMap (story time) <| items 

{-| Create a Story from a HN Item if it is a Story. -}
story : Time.Time -> HN.Item -> Maybe Story
story time item =
    if item.kind == "story" then
        Just (Story item <| rank time item)
    else
        Nothing

{-| Calculates the page rank of an Item at a given Time. -}
rank : Time.Time -> HN.Item -> Float
rank time item =
    let
        age = (Time.inSeconds time) - item.time
        hours = age / 3600
        base = if item.score <= 1 then 0.0 else toFloat item.score ^ 0.8
        rank = base / ((hours + 2) ^ 1.8)
    in
    case item.url of
        Just _ -> rank
        Nothing -> rank * 0.4

{-| Sort a list of stories by rank. -}
sortByRank : List Story -> List Story
sortByRank =
    List.sortBy (\s -> -s.rank)

{-| Sort a list of stories by time. -}
sortByTime : List Story -> List Story
sortByTime =
    List.sortBy (\s -> -s.item.time)