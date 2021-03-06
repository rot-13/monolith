class Monolith.Views.PlayerView extends Backbone.Marionette.LayoutView
  className: 'player'
  template: '#player-view-template'

  regions:
    rows: '.rows-region'
    playerInfo: '.player-info-region'
    hand: '.hand-region'

  onRender: ->
    @$el.addClass(@model.get('type'))
    @rows.show(new Monolith.Views.RowCollectionView(collection: @model.get('rows'), side: @model.get('side')))
    @hand.show(new Monolith.Views.HandView(collection: @model.get('hand'))) if @model.has('hand')
    @playerInfo.show(new Monolith.Views.PlayerInfoView(model: @model))
