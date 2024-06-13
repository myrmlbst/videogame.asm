.data
	colorGreen:		.word 0x0001f901        # 01f901 green in hexadecimal
	colorWhite:		.word 0x00ffffff        # change to white
	colorBG:		.word 0x00000000        # BG color (black)
	coorX:			.word 0		        # initial x coordinates
	coorY:			.word 31	        # initial y coordinates
	colorRed:		.word 0x00FF0000	# red (player)
	widthDisplay:		.word 64
	velocity: 		.word 50	        # speed
	direction:		.word 119
	enemy1X:		.word 63
	enemy1Y: 		.word 11
	enemy2X:		.word 63
	enemy2Y: 		.word 38
	enemy3X:		.word 63
	enemy3Y: 		.word 62
	colorEnemy:		.word 0x00000ff04 
	velocityEnemy:		.word 0
	firstShoot:		.word 0                 # starts the loop
	firstShootY:		.word 0		  
	LastVal:		.word 0
	score:			.word 0
	scoreInitial:		.word 0		
	seconds:		.word 0	
	timeEnemy:		.word 0		        # time at which enemy moves

.text
li $a0, 0		
sw $a0, First Game

NewGame:
	li $a0, 0		                        # load 0 on parameters
	sw $a0, lives
	sw $a0, velocityEnemy
	sw $a0, firstShoot
	sw $a0, LastVal
	sw $a0, score
	sw $a0, scoreInitial
	sw $a0, sec
	li $a0, 11		
	sw $a0, timeEnemy
	jal ClearBoard                     		# screen turns black
	NoFirstGame:
	jal ClearBoard                   	 	# returns a black screen
	
SelectMode:                                		# get data from keyboard:                                             
		lw $t1, 0xFFFF0004		        # check to see which key has been pressed
		beq $t1, 0x00000065, GameStart          # if press on lowercase 'e'
		li $a0, 250
		li $v0, 32	                        # pause for 250 milliseconds
		syscall		
		j SelectMode                            # jump back to the top of the wait loop
		sw $zero, 0xFFFF0000		        # clear the button pushed bit
         
GameStart:                  				
	# initializing the variables: 
	li $a0, 1			            	# load 1 on $a0	
	sw $a0, FirstGame      				# save 1 in FirstGame, this way we know that at least one game has already occurred
	li $t0, 1                 			# player initial coordinates
	sw $t0, coorX
	li $t0, 31
	sw $t0, coorY
	li $t0, 50
	sw $t0, velocity
	li $t0, 63
	sw $t0, enemy1X
	sw $t0, enemy2X
	sw $t0, enemy3X
	li $t0, 11
	sw $t0, enemy1Y
	li $t0, 38
	sw $t0, enemy2Y
	li $t0, 62
	sw $t0, enemy3Y

	# our initial position:
	li $a0, 1               		
	lw $a0, coorX		
	lw $a1, coorY 	
	jal ObtainCoordinates
	move $a0, $v0		
	lw $a1, halconColor

	# initial position of the enemies:                 
	li $a0, 1          				# enemy 1
	lw $a0, coor1X		
	lw $a1, coor1Y		
	jal ObtainCoordinates
	move $a0, $v0		
	lw $a1, colorEnemy
	li $a0, 1        				# enemy 2
	lw $a0, coor2X		
	lw $a1, coor2Y		
	jal ObtainCoordinates
	move $a0, $v0		
	lw $a1, colorEnemy
	li $a0, 1       				# enemy 3
	lw $a0, coor3X		
	lw $a1, coor3Y		
	jal ObtainCoordinates
	move $a0, $v0		
	lw $a1, colorEnemy

# Update player position
NewDirection:
	beq $t7, 119, DrawUp         			# w	
	beq  $t7, 115, DrawDown      			# s
	beq $t7, 104, Shoot          			# shoot when 'h' is pressed
	jal moveEnemy			
movEnemy:
	lw $a0, Score					# load Score value into $a0
	sw $a0, InitialScore				# saves Score value in InitialScore
	sw $a0, Score					# save unit in Score
	lw $a0, InitialScore				# load the InitialScore
	sw $a0, Score					# save it in Score so that it returns to the current value
	
	# enemy 2's movements
	li $a0, 1
	lw $a0, enemy2X
	lw $a1, enemy2Y

	jal enemyclash2
	# Draw the new position and move Y coordinates
	lw $t0, enemy2X
	lw $t1, enemy2Y
	addi $t0, $t0, -1
	add $a1, $t1, $zero	
	add $a0, $t0, $zero 	
	jal ObtainCoordinates
	add $a0, $v0, $zero	
	lw $a1, ColorEnemy
	jal DrawPixel
	sw $t0, enemy2X
	
	# Delete previous pixel
	lw $t0, enemy2X
	lw $t1, enemy2Y
	addi $t0, $t0, 1
	add $a1, $t1, $zero			# it does not move in X, so it adds 0
	add $a0, $t0, $zero 			# it removes a position from Y and saves it in a1
	jal ObtainCoordinates
	add $a0, $v0, $zero			# add 0 to the coordinate and save it in a0
	lw $a1, colorBG
	jal DrawPixel
	
	# enemy 3's movements 3
	li $a0, 1
	lw $a0, enemy3X
	lw $a1, enemy3Y

	jal enemyclash3
	# Draw the new position and move in Y
	lw $t0, enemy3X
	lw $t1, enemy3Y
	addi $t0, $t0, -1
	add $a1, $t1, $zero			# it does not move in Y, so it adds 0
	add $a0, $t0, $zero 	
	jal ObtainCoordinates
	add $a0, $v0, $zero			# add 0 to the coordinate and save it in a0
	lw $a1, colorEnemy
	jal DrawPixel
	sw $t0, enemy3X
	
	# Delete previous pixel
	lw $t0, enemy3X
	lw $t1, enemy3Y
	addiu $t0, $t0, 1
	add $a1, $t1, $zero			# it does not move in X, so it adds 0
	add $a0, $t0, $zero 
	jal ObtainCoordinates
	add $a0, $v0, $zero	
	lw $a1, colorBG
	jal DrawPixel
	
	j NewKey

SHooting: 
	lw $a0, firstShoot
	bnez $a0, leapShoot			# if StartShot is equal to zero then load the y coordinate of the player
	
	lw $a1, halconY   			# loads the Y coordinate of the ship in $a1, we only use this at the time of shooting, so it should only be loaded at that moment
	sw $a1, ShootingY  			# saves the initial Y coordinate in ShotY
	addi $a0, $a0, 1
	
Delete:
		#Delete: (if the x coordinate is greater than 1)
		blt $a0, 2, NoDeletion    	# delete (but dont delete the first) so we start deleting at 1
		sw $a0, firstShoot   		# save the new value of $a0
		lw $a0, firstShoot		# load the new value of $a0
		lw $a1, DeleteY			# load the y position of the shot
		lw $a2, BGColor			# load the background color to paint a black dot in the previous position
		jal DrawPoint 			# delete the shot with the previous coordinates
		NoDelete:   			# If the shot is at the start, it does not delete it
		addi $a0, $a0, 1 		# adds 1 so that it does not reload the initial y coordinate
		sw $a0, firstShoot   		# save the new value of $a0 
		lw $a0, firstShoot 
		lw $a1, DeleteY
		lw $a2, colorWhite
		jal DrawPoint 			# draw the shot with the previous coordinates
		
		# Projectile Collision 1:
		lw $a0, enemy1Y				# load the enemy's y position
		lw $a1, DeleteY				# load the y position of the shot
		bne $a0, $a1, NoCollisionShot1		# compares the y position of the enemy with that of the shot (if they are equal: it will compare the positions in x. if not: the label jumps because they do not collide)
		lw $a0, enemy1X				# load enemy x position	
		lw $a1, firstShoot			# load the x position of the shot
		bne $a0, $a1, NoCollisionShot1		# compare the positions in x, if they are equal it will reset the shot AND the enemy
		lw $a0, InitialShooting			# load the x position of the shot
		lw $a1, firstShoot			# load the y position of the shot
		lw $a2, BGColor				# load the background color
		jal DrawPoint 				# delete the shot at the last point
		li $a0, 0				# zero charge on $a0
		sw $a0, InitialShooting			
		
		li $a1, 16  				# the maximum number is placed here
   		li $v0, 42  				# generate the random number
    		syscall
    		add $a0, $a0, 12
    		
    		sw $a0, enemy1Y
		li $a0, 63				# load 63 in $a0
		sw $a0, enemy1X				# save 63 at the enemy's position at x, thus returning the enemy to the initial position at x
		lw $a0, Score				# load Score to add 1
		addi $a0, $a0, 1			# adds 1 to Score because of an enemy hit
		sw $a0, Score				# save the value of the new score
		
		NoCollisionShot1:
		#Projectile Collision 2:
		lw $a0, enemy2Y				# load the enemy's y position
		lw $a1, ShotY				# load the y position of the shot
		bne $a0, $a1, NoCollisionShot2		# compares the y position of the enemy with that of the shot, if they are equal it will compare the positions in x, if not the label jumps because it does not collide
		lw $a0, enemy2X				# load enemy x position	
		lw $a1, InitialShooting			# load the x position of the shot
		bne $a0, $a1, NoCollisionShot2   	# compare the positions in x, if they are equal it will reset the shot and the enemy
		lw $a0, InitialShooting			# load the x position of the shot
		lw $a1, ShotY				# load the y position of the shot
		lw $a2, ColorBG				# load the background color
		jal DrawPoint 				# delete the shot at the last point
		li $a0, 0				
		sw $a0, InitialShooting				
		
		li $a1, 16  				# the maximum number is placed here
   		li $v0, 42  				# generate the random number
    		syscall
    		add $a0, $a0, 29
    		
    		sw $a0, enemy2Y
		li $a0, 63				# load 63 in $a0
		sw $a0, enemy2X				# save 63 at the enemy's position at x, thus returning the enemy to the initial position at x
		lw $a0, Score				# load Score to add 1
		addi $a0, $a0, 1			# adds 1 to Score (because an enemy hit)
		sw $a0, Score				# save the new value of Score
		
		NoCollisionShot2:
		#Projectile Collision 3:
		lw $a0, enemiy3Y			# load the enemy's y position
		lw $a1, ShotY				
		bne $a0, $a1, NoCollisionShot3		# compares the y position of the enemy with that of the shot, if they are equal it will compare the positions in x, if not it jumps because they do not collide
		lw $a0, enemy3X				# load the enemy's x position	
		lw $a1, InitialShooting			
		bne $a0, $a1, NoCollisionShot3		# compare the positions in x, if they are equal it will reset the shot and the enemy
		lw $a0, InitialShooting			# load the x position of the shot
		lw $a1, ShotY				# load the y position of the shot
		lw $a2, ColorBG				# load the background color
		jal DrawPoint 				# delete the shot at the last point
		li $a0, 0				# zero charge on $a0
		sw $a0, HomeShooting			# resets
		
		li $a1, 16  				# the maximum number is placed here
   		li $v0, 42 				# generate the random number
    		syscall
    		add $a0, $a0, 46
    		
    		sw $a0, enemy3Y
		li $a0, 63				# load 63 in $a0
		sw $a0, enemy3X				# save 63 at the enemy's position at x, thus returning the enemy to the initial position at x
		lw $a0, Score				# load Score to add 1
		addi $a0, $a0, 1			# sdds 1 to Score because an enemy hit
		sw $a0, Score				# save the new Score value
		
		NoCollisionShot3:
		lw $a0, InitialShooting
		bne $a0, 63, RestartShooting		# if it reaches the end of the screen, it restarts shooting
		lw $a0, InitialShooting
		lw $a1, ShootingY
		lw $a2, ColorBG
		jal DrawPoint 				# delete the shot at the last point
		li $a0, 0
		sw $a0, InitialShooting
		
		RestartShooting:   
		
	jal moveEnemy 				        # jump and link so that the enemy's movement does not stop	
		
	# Delete previous pixel
	lw $t0, ShotX
	lw $t1, ShotY
	addiu $t1, $t1, 1
	add $a0, $t0, $zero				# it does not move in X, so it adds 0
	add $a1, $t1, $zero 				# it removes a position from Y and saves it in a1
	jal ObtainCoordinates
	add $a0, $v0, $zero				# add 0 to the coordinate and save it in a0
	lw $a1, ColorBG
	jal DrawPixel
	
	lw $a0, InitialShooting 			
	bnez $a0, JumpShoot 			
		
	j moveEnemy

DrawDown:
	lw $a0, ShotX
	lw $a1, ShotY
	lw $a2, direccion
	
	jal Shock					# draw the new position and move in Y
	lw $t0, ShotX
	lw $t1, ShotY
	addiu $t1, $t1, 1
	add $a0, $t0, $zero				# it does not move in X, so it adds 0
	add $a1, $t1, $zero 				# it removes a position from Y and saves it in a1
	jal ObtainCoordinates
	add $a0, $v0, $zero				# add 0 to the coordinate and save it in a0
	lw $a1, ShotColor
	jal DrawPixel
	sw $t1, ShotY
	
	# Delete previous pixel
	lw $t0, ShotX
	lw $t1, ShotY
	addiu $t1, $t1, -1
	add $a0, $t0, $zero				# it does not move in X, so it adds 0
	add $a1, $t1, $zero 				# it removes a position from Y and saves it in a1
	jal ObtainCoordinates
	add $a0, $v0, $zero				# add 0 to the coordinate and save it in a0
	lw $a1, ColorBG
	jal DrawPixel
	lw $a0, InitialShooting 			# save in $a0
	bnez $a0, JumpSHoot 				# if it is different from zero, it makes a branch to JumpShoot
	
	j moveEnemy

# Get coordinates for the player's address  	
ObtainCoordinates:
	lw $v0, widthDisplay				# gets the width of the screen
	mul $v0, $v0, $a1				# multiply the width by the Y position
	add $v0, $v0, $a0				# adds the position in X to the previous result
	mul $v0, $v0, 4					# multiply by 4 to get direction
	add $v0, $v0, $gp				# adds a screen pointer to the coordinate
	jr $ra			 
			
# Collision:	
Shock:
	# Save player coordinates
	add $s3, $a0, $zero
	add $s4, $a1, $zero
	
	# Save return address
	sw $ra, 0($sp)
	
	beq $a2, 119, CheckTop
	beq $a2, 115, CheckBelow
	j CrashReady

CheckTop:
	addiu $a1, $a1, -1
	jal ObtainCoordinates
	# get background color
	lw $t1, 0($v0)
	lw $t3, barColor
	beq $t1, $t3, moveEnemy 			# compare the player's color to the color of the walls above
	j CrashReady

CheckBelow:
	addiu $a1, $a1, 1
	jal ObtainCoordinates
	# obtain background color
	lw $t1, 0($v0)
	lw $t3, barColor
	beq $t1, $t3, movEnemigo 			# compare the color of the player with the color of the walls below
	j CrashReady

CrashReady:
	lw $ra, 0($sp) 					# returns the address of the stack at the beginning
	jr $ra
CrashEnemy1:
	add $s3, $a0, $zero				# position in X
	add $s4, $a1, $zero				# Y position
	sw $ra, 0($sp)					# save return address
	addiu $a0, $a0, -1
	jal ObtainCoordinates
	
	# Get background color
	lw $t1, 0($v0)
	lw $t3, barColor
	beq $t1, $t3, Exit1 				# compare the color of the enemy with the color of the wall on the left
	lw $t3, shootColor
	beq $t1, $t3, Exit1
	lw $ra, 0($sp)
	jr $ra

ClashEnemy2:
	add $s3, $a0, $zero				# position in X
	add $s4, $a1, $zero				# position in Y
	sw $ra, 0($sp)					# save return address
	
	addiu $a0, $a0, -1
	jal ObtainCoordinates
	
	lw $t1, 0($v0)					  # get background color
	lw $t3, barColor
	beq $t1, $t3, Exit2 				# compare the color of the enemy with the color of the wall on the left
	lw $t3, Color
	beq $t1, $t3, Exit2
	lw $ra, 0($sp)
	jr $ra

ClashEnemy3:
	add $s3, $a0, $zero				# position in X
	add $s4, $a1, $zero				# position in Y
	sw $ra, 0($sp)					# save return address
	
	addiu $a0, $a0, -1
	jal ObtainCoordinates
	
	lw $t1, 0($v0)					# obtains background color
	lw $t3, barColor
	beq $t1, $t3, Exit3 				# compares the color of the enemy with the color of the wall on the left
	lw $t3, Color
	beq $t1, $t3, Exit3
	lw $ra, 0($sp)
	jr $ra

Exit1:
	# Enemy 1 disappears
	lw $t0, enemy1X
	addiu $t0, $t0, -1
	sw $t0, enemy1X
	
	# delete previous pixel
	lw $t0, enemy1X
	lw $t1, enemy1Y
	addiu $t0, $t0, 1
	add $a1, $t1, $zero				# it does not move in X, so it adds 0
	add $a0, $t0, $zero 				# it removes a position from Y and saves it in a1
	jal ObtainCoordinates
	add $a0, $v0, $zero				# add 0 to the coordinate and save it in a0
	lw $a1, ColorBG
	jal DrawPixel
	
	# count the lives
	lw $a0, lives
	addi $a0, $a0, 1
	sw $a0, lives
	bne $a0, 4, NewEnemy1				# returns the enemy to its initial conditions
	j NewGame

Exit2:
	# enemy 2 disappears
	lw $t0, enemy2X
	addiu $t0, $t0, -1
	sw $t0, enemy2X
	
	# delete previous pixel
	lw $t0, enemy2X
	lw $t1, enemy2Y
	addiu $t0, $t0, 1
	add $a1, $t1, $zero				# it does not move in X, so it adds 0
	add $a0, $t0, $zero 				# it removes a position from Y and saves it in a1
	jal ObtainCoordinates
	add $a0, $v0, $zero				# add 0 to the coordinate and save it in a0
	lw $a1, ColorBG
	jal DrawPixel
	
	# Count the lives
	lw $a0, lives
	addi $a0, $a0, 1
	sw $a0, lives
	bne $a0, 4, NewEnemy2				# returns the enemy to its initial conditions
	j NewGame

Exit3:
	# enemy 3 disappears
	lw $t0, enemy3X
	addiu $t0, $t0, -1
	sw $t0, enemy3X
	
	# delete previous pixel
	lw $t0, enemy3X
	lw $t1, enemy3Y
	addiu $t0, $t0, 1
	add $a1, $t1, $zero				# it does not move in X, so it adds 0
	add $a0, $t0, $zero 				# removes a position from Y and saves it in a1
	jal ObtainCoordinates
	add $a0, $v0, $zero				# add 0 to the coordinate and save it in a0
	lw $a1, ColorBG
	jal DrawPixel

	# count the lives
	lw $a0, lives
	addi $a0, $a0, 1
	sw $a0, lives
	bne $a0, 4, NewEnemy3				# returns the enemy to its initial conditions
	j NewGame

NewEnemy1:
	# return enemy 1 to its initial position
	li $t0, 63
	sw $t0, enemy1X
	li $t0, 11
	sw $t0, enemy1Y

	# draw the initial position of the enemy
	lw $a0, enemy1X					# load the player's X coordinate into a0
	lw $a1, enemy1Y					# load the player's Y coordinate into a0
	jal ObtainCoordinates
	move $a0, $v0					# copy coordinates to a0, since they are saved in v0
	lw $a1, enemyColor				# stores the player's color
	jal DrawPixel					# color the pixel
	j DrawLives

NewEnemy2:
	# return enemy 2 to its initial position
	li $t0, 63
	sw $t0, enemy2X
	li $t0, 38
	sw $t0, enemy2Y

	# draw the initial position of the enemy
	lw $a0, enemy2X					# load the player's X coordinate into a0
	lw $a1, enemy2Y					# load the player's Y coordinate into a0
	jal ObtainCoordinates
	move $a0, $v0					# copy coordinates to a0, since they are saved in v0
	lw $a1, enemyColor				# stores the player's color
	jal DrawPixel					# color the pixel
	j DrawLives

NewEnemy3:
	# return enemy 3 to its initial position
	li $t0, 63
	sw $t0, enemy3X
	li $t0, 62
	sw $t0, enemy3Y

	# draw the initial position of the enemy
	lw $a0, enemy3X					# load the player's X coordinate into a0
	lw $a1, enemy3Y					# load the player's Y coordinate into a0
	jal ObtainCoordinates
	move $a0, $v0					# copy coordinates to a0, since they are saved in v0
	lw $a1, enemyColor				# stores the player's color
	jal DrawPixel					# color the pixel
	j DrawLives
