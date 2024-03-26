extends Node2D

var center = Vector2(576-150,324)
var red = Color(1,0,0)
var green = Color(0,1,0)
var black = Color(0,0,0)
var projectiles = 5
var landingRadius = 1
var enemySizes = [2, 3, 5, 11]
var enemySize = 3
var beamWidth = 1
var arrowCount = 100
var areaMulti = 1

var arrows : Array
var closestPoint
var closestPointIsOnLine = true

var hits : float = 0
var beams : float = 1
var overlap = 0.0
var iterations : int = 0
var auto = false
var regex = RegEx.new()
var text = ""
var oldtext = ""


func _ready():
	regex.compile("^\\d*\\.?\\d*$")
	areaMulti = float($Panel/Area2.get_text())
	
	overlap = snapped(hits/beams, 0.001)
	enemySize = enemySizes[$Panel/EnemySize2.selected] * 10.0
	projectiles = $Panel/ProjectileNumber2.value
	$Panel/EnemySize2.selected = 1
	$Panel/Area2.set_text("1.0")
	landingRadius = snapped((0.5 + projectiles * 0.5 * sqrt(areaMulti)) * 100,0.1)
	generateRandomPoints()


func _physics_process(delta):
	areaMulti = float($Panel/Area2.get_text())
	landingRadius = snapped((0.5 + projectiles * 0.5 * sqrt(areaMulti)) * 100,0.1)
	overlap = snapped(hits/beams, 0.001)
	enemySize = enemySizes[$Panel/EnemySize2.selected] * 10.0
	projectiles = $Panel/ProjectileNumber2.value
	$Panel/Overlap.set_text("Beam hit ratio: ")
	$Panel/Overlap2.set_text(str(overlap*100) + "% (" + str(hits) + "/" + str(beams) + ")")
	$Panel/RadiusRatio.set_text("Radius ratio: " + str(snapped(enemySize/(landingRadius/100),0.1)) + "% (" + str(enemySize/100.0) + "m/" + str(landingRadius/100) + "m)")
	$Panel/EnemySize.set_text("Enemy Size: ")
	$Panel/ProjectileNumber.set_text("Number of Projectiles: " + str($Panel/ProjectileNumber2.value))
	if auto:
		generateRandomPoints()



func _draw():
	var index = 0
	for item in arrows:
		draw_circle(item,3,black)
		var rng = randi_range(0,arrows.size()-1)
		while rng == index:
			rng = randi_range(0,arrows.size()-1)
		var color = red
		getClosestPoint(item, arrows[rng])
		#draw_circle(closestPoint,5,black)
		if item.distance_to(center) < enemySize or arrows[rng].distance_to(center) < enemySize:
			color = green
		elif closestPoint.distance_to(center) < enemySize and closestPointIsOnLine:
			color = green
		draw_line(item,arrows[rng],color,beamWidth,true)
		beams += 1
		if color == green:
			hits += 1
		index += 1
	draw_arc(center,landingRadius,0,2*PI,100,black,2,true)
	draw_arc(center,enemySize,0,2*PI,100,black,2,true)



func getClosestPoint(point1, point2):
	closestPointIsOnLine = true
	var distX = point1.x - point2.x
	var distY = point1.y - point2.y
	var length = sqrt(distX*distX + distY*distY)
	var cx = center.x
	var cy = center.y
	var dotProduct = (((cx-point1.x)*(point2.x-point1.x)) + ((cy-point1.y)*(point2.y-point1.y))) / pow(length,2)
	var closestX = point1.x + (dotProduct * (point2.x-point1.x))
	var closestY = point1.y + (dotProduct * (point2.y-point1.y))
	closestPoint = Vector2(closestX,closestY)
	var d1 = point1.distance_to(closestPoint)
	var d2 = point2.distance_to(closestPoint)
	if d1 + d2 > length+1:
		closestPointIsOnLine = false




func generateRandomPoints():
	arrows = []
	var i = 0
	while i < arrowCount:
		var dist = randf_range(0,landingRadius)
		var rota = randf_range(0,2*PI)
		var x = dist * cos(rota)
		var y = dist * sin(rota)
		var location = Vector2(center.x + x,center.y + y)
		#var location = center + Vector2(randf_range(-landingRadius,landingRadius),randf_range(-landingRadius,landingRadius))
		if location.distance_to(center) < landingRadius:
			arrows.append(location)
			i += 1
	queue_redraw()
	iterations += 1




func _on_button_button_up():
	generateRandomPoints()



func _on_reset_button_up():
	hits = 0
	beams = 0



func _on_check_box_toggled(toggled_on):
	if toggled_on:
		auto = true
	else:
		auto = false



func _on_area_2_text_changed(new_text):
	if regex.search(new_text):
		text = new_text   
		oldtext = text
	else:
		text = oldtext
	$Panel/Area2.set_text(text)
	$Panel/Area2.set_caret_column(text.length())
