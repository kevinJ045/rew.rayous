import { Component, Widget, Text } from "rayous";

export default class extends Component
  build: (props) ->
    console.log props
    new Widget children: [
      new Text 'hello, rayousXrew'
    ]