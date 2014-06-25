'use strict'

app.controller 'GameCtrl', ['$scope', 'User', 'Auth', 'Map', 'Hero', 'Enemy', 'Player', 'Events', 'Socket', 'PlayerAPI', 'MapAPI', 'SERVER_URL'
 ($scope, User, Auth, Map, Hero, Enemy, Player, Events, Socket, PlayerAPI, MapAPI, SERVER_URL) ->
  $scope.currentUser = window.userData || {name: "test"}
  $scope.chats = []
  $scope.sendChat = ->
    chat = 
      user: $scope.currentUser.name
      message: $scope.chatToSend
    game.message chat
    $scope.chats.push chat
    $scope.chatToSend = ''
    do $scope.chats.shift while $scope.chats.length > 100

  $scope.borders = 
    up: true
    right: true
    down: true
    left: true

  $scope.makeMap = (direction) ->
    console.log(direction)
    MapAPI.makeMap().get({direction: direction, mapId: mapId})

  app = Events({})
  window.game = game = null
  hero = null
  map = null
  players = Events({})
  mapId = null
  initialMap = null
  upScreen = null
  rightScreen = null
  downScreen = null
  leftScreen = null
  png = null
  rootUrl = ''
  user = $scope.currentUser.name
  initPos = {}
  explosions = null
  
  # MAKE INITIAL AJAX CALL FOR PLAYER INFO
  initialize = ->
    PlayerAPI.get (playerInfo) ->
      mapId = playerInfo.mapId
      initPos.x = playerInfo.x
      initPos.y = playerInfo.y

      png = playerInfo.png || 'roshan'
      $scope.mapId = mapId
      MapAPI.getMap().get {mapId: mapId}, (mapData) ->
        initialMap = mapData
        console.log(mapData)
        game = new Phaser.Game(800, 600, Phaser.AUTO, "game-canvas",
          preload: preload
          create: create
          update: update
        )
        game.rootUrl = rootUrl
        game.enemies = []
        game = Events(game)
        game.realWidth = 20 * 64
        game.realHeight = 12 * 64


  preload = ->

    game.load.atlasXML "enemy", "assets/enemy.png", "assets/enemy.xml"
    hero = Events(Hero(game, Phaser, {
      exp: 150
      health: 100
      mana: 100
      str: 10
      dex: 10
      int: 10
      luk: 10
      x: initPos.x
      y: initPos.y
      png: png
    }))
    # window.hero = hero
    map = Events(Map(game, Phaser, mapId, $))
    game.user = user
    game.map = map
    Socket SERVER_URL, game, players, Phaser
    game.load.spritesheet 'kaboom', 'assets/explosion.png', 64, 64, 23
    console.log(hero)
    hero.preload()
    map.preload(null, initialMap)

    app.trigger 'create'
    app.isLoaded = true

    window.game = game
    game.hero = hero
    game._createCtrls = _createCtrls

  create = ->
    map.create()
    hero.create()
    game.hero = hero
    createExplosions()
    # render()

    map.on 'finishLoad', =>
      hero.arrow.arrows.destroy()
      hero.createArrows()
      createExplosions()
      app.isLoaded = true
      render()

    console.log "Joining #{game.mapId} on #{hero.sprite.x},#{hero.sprite.y}"


    enemies = []
    enemyPositions = {}

    for enemyId of initialMap.enemies
      enemies.push 
        id: enemyId
        count: initialMap.enemies[enemyId].count
      enemyPositions[enemyId] = initialMap.enemies[enemyId].positions

    game.enemyPositions = enemyPositions

    game.camera.follow(hero.sprite);

    game.join
      x: hero.sprite.x
      y: hero.sprite.y
      enemies: enemies
      positions: enemyPositions

  render = ->
    game.layerRendering = game.add.group()
    game.layerRendering.add(map.layers[0])
    game.layerRendering.add(map.layers[1])
    game.layerRendering.add(map.layers[2])
    game.layerRendering.add(hero.sprite)
    game.layerRendering.add(hero.arrow.arrows)
    game.layerRendering.add(explosions)
    game.layerRendering.add(map.layers[3])
    # hero.sprite.bringToTop();

  update = ->
    if app.isLoaded
      map.update()
      hero.update()
      for enemy in game.enemies
        if enemy.alive
          hero.sprite.facing = hero.facing
          game.physics.arcade.collide(hero.sprite, enemy.sprite, hurtHero, null, hero)
          game.physics.arcade.collide(hero.arrow.arrows, hero.sprite, arrowHurt, null, hero)
          # game.physics.arcade.collide(hero.arrow.arrows, player.sprite, arrowHurt, null, player)
          game.physics.arcade.collide(hero.arrow.arrows, enemy.sprite, arrowHurt, null, enemy)

          enemy.update()
      for player of players
        if player.update then do player.update

  hurtHero = (heroSprite, enemySprite) ->
    @damage()

  arrowHurt = (sprite, arrow) ->
    explosions.call(@)
    @damage()
    arrow.kill()

  createExplosions = ->
    explosions = game.add.group()

    for i in [0...10]
      explosionAnimation = explosions.create(0, 0, 'kaboom', [0], false)
      explosionAnimation.anchor.setTo(0.5, 0.5)
      explosionAnimation.animations.add('kaboom')

  explosion = ->
    explosionAnimation = explosions.getFirstExists(false)
    explosionAnimation.reset(@sprite.x, @sprite.y)
    explosionAnimation.play('kaboom', 30, false, true)

  _createCtrls = (data) ->
    $scope.mapId = map.mapId
    borders = 
      upScreen: data.upScreen
      rightScreen: data.rightScreen
      downScreen: data.downScreen
      leftScreen: data.leftScreen

    $scope.$apply ->
      for border, value of borders
        borderDirection = border.split('Screen')[0]
        $scope.borders[borderDirection] = !!value
        map.game.physics.arcade.checkCollision[borderDirection] = !value  
    

  do initialize


]
