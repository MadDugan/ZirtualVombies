// Global variables
float radius = 50.0;
int halfWidth, halfHeight;
int X, Y;
int nX, nY;
int delay = 16;
int gameState = 0;
int startFrame = 0;
int currentFrame = 0;
/*
0 - start screen
1 - play
2 - win
3 - death
*/
Player player;
Zombiemanager zm;
boolean canFire = false;
int killCount = 0;

int difficulty[] = {30, 20, 10, 5, 2};
int currentDifficulty = 0;

// Setup the Processing Canvas
void setup(){
	size( 1024, 768 );
	strokeWeight( 2 );
	frameRate( 30 );
	halfWidth = width / 2;
	halfHeight = height / 2;
	X = halfWidth;
	Y = halfHeight;
	nX = halfWidth;
	nY = halfHeight;


}

// Main draw loop
void draw(){

	currentFrame = (frameCount - startFrame);

	// Fill canvas grey
	background( 100 );

	switch (gameState){
		case 0:
			startFrame = frameCount;
			killCount = 0;
			currentDifficulty = 0;
			
			player = new Player(halfWidth, halfHeight);
			zm = new ZombieManager(150);		
		
			for(int i=0;i<20;i++) {
				zm.addZombie();
			}
			drawStart();
			break;
		case 1:
			drawPlay();
			break;
		case 2:
			drawPlay();
			drawGameOver();
			break;
		case 3:
			break;
	}
}

void drawPlay () {
	player.draw();

	// add zombies periodically based on difficulty
	if(!(currentFrame % difficulty[currentDifficulty])){
		zm.addZombie();
	}

	// increase difficulty every 1000 frames
	if(!(currentFrame % 1000)) {
		currentDifficulty++;

		if(currentDifficulty > 4)
			currentDifficulty = 4;
	}

	zm.run();

	// killCount
	textSize(20);
	fill( 255, 255, 255 );
	str = "Kills: " + killCount;
	text(str, 10, 20);
}

void drawStart() {
	// dead

	textSize(75);
	textAlign(CENTER);
	
	fill( 0, 0, 0 );
	text("Zirtual Vombies", (width/2), height/2-85);
	
	fill( 255, 255, 255 );
	text("Zirtual Vombies", (width/2)+5, height/2-90);
	
	if((currentFrame % 2) != 0) {
		textSize(25);
		fill( 255, 255, 255 );
		text("Press SPACE to start", (width/2), height/2+85);
	}
}

void drawGameOver() {
	// dead

	textSize(75);
	fill( 255, 255, 255 );
	textAlign(CENTER);
	text("GAME OVER", (width/2), height/2-85);
	
	textSize(25);
	fill( 255, 255, 255 );
	text("Press SPACE to try again", (width/2), height/2+85);
}

// Set circle's next destination
void mouseMoved(){
	nX = mouseX;
	nY = mouseY;
}

void mouseDragged() {
	nX = mouseX;
	nY = mouseY;
}

void mousePressed() {
	switch(mouseButton){
		case 37: // Left Mouse
			//player.fire();
			canFire = true;
			break;
	}
}

void mouseReleased() {
	switch(mouseButton){
		case 37: // Left Mouse
			canFire = false;
			break;
	}
}

void keyPressed (){
	if(key == ' ') {
		switch(gameState) {
			case 0:
				gameState = 1;
				break;
			case 2:
				gameState = 0;
				break;
		}
	}
}

class Player
{
	float x, y, angle, radius;
	int maxBullets = 50;
	int health = 100;

	ArrayList bullets;

	Player(int x, int y) {
		this.x = x;
		this.y = y;
		this.radius = 50.0;

		this.bullets = new ArrayList();
	}

	void draw() {

		//draw bullets
		for(int i=bullets.size()-1;i>=0;i--){
			bullet b = (bullet) bullets.get(i);

			b.move();

			if(!b.alive)
				bullets.remove(i);
			else
				b.draw();
		}

		if(this.health > 0) {

			if(canFire) {
				// only fire every 4th frame
				if(!(currentFrame % 4))
					player.fire();
			}

			this.radius = this.radius + (sin( currentFrame / 4 ) / 2);

			float dx = nX - this.x;
			float dy = nY - this.y;

			this.angle = atan2(dy, dx);

			pushMatrix();
			translate(this.x, this.y);
			rotate(this.angle);
			// Set stroke-color black
			stroke(000);

			// Draw player
			// Set fill-color to blue
			fill( 0, 121, 184 );
			ellipse( 0, 0, this.radius /2 , this.radius );

			// Set fill-color to light blue
			fill( 0, 121, 255 );
			ellipse( 0, 0, this.radius / 2, this.radius / 2 );
			popMatrix();
		} else {
			// draw blood puddle?
		}
	}

	void fire (){
		console.log('Fire called');
		if(bullets.size() > maxBullets-1)
			return;
		bullets.add(new Bullet(x, y, angle));
	}

	void takeDamage() {
		this.health--;

		if(this.health <= 0) {

			this.health = 0;
			gameState = 2;
		}
	}
}

class Zombie
{
	float x, y, angle, radius;
	float size = 35;
	boolean alive;
	int hit;

	Zombie(int x, int y) {
		this.x = x;
		this.y = y;
		this.radius = 50.0;
		this.alive = true;
		this.hit = 0;
		this.rand = Math.random() * 100;
	}

	// always face player.
	void draw(boolean canMove) {

		this.radius = this.radius + (sin( (this.rand + currentFrame) / 3 ) / 2);

		float dx = player.x - this.x;
		float dy = player.y - this.y;
		this.angle = atan2(dy, dx);

		pushMatrix();
		
		if(canMove && !this.hit) {
			mag = Math.sqrt(dx*dx + dy*dy);

			this.x += (0.75) * ((player.x - this.x) / mag);
			this.y += (0.75) * ((player.y - this.y) / mag);
		}
			
		translate(this.x, this.y);
		rotate(this.angle);
		
		if(this.hit > 0) {
			if((hit + 15) < currentFrame) {
				this.alive = false;
			}
			scale((15.0 - (currentFrame - this.hit)) / 15.0);
		}
		
		// Set stroke-color black
		stroke(000);

		// Draw Zombie
		// Set fill-color to green
		fill( 0, 184, 121 );
		ellipse( 0, 0, this.radius /2 , this.radius );

		// Set fill-color to light green
		fill( 0, 255, 121);
		ellipse( 0, 0, this.radius / 2, this.radius / 2 );
		popMatrix();

	}
}

class ZombieManager
{
	ArrayList zombies;
	int maxCount;

	ZombieManager(int num) {
		this.zombies = new ArrayList();
		this.maxCount = num;
	}

	void run() {
		// Cycle through the ArrayList backwards b/c we are deleting
		for (int i = zombies.size()-1; i >= 0; i--) {
			Zombie z = (Zombie) zombies.get(i);

			if(!z.alive) {
				zombies.remove(i);
			} else {
				// test if hitting player
				{
					float dx = player.x - z.x;
					float dy = player.y - z.y;
					float dist = Math.sqrt(dx*dx + dy*dy);

					if(dist < z.size) {
						// player take damage
						player.takeDamage();
						canMove = false;
					}
				}

				// test if it can move
				boolean canMove = true;
				for (int j = 0; j < i; j++) {
					// simple collision test
					Zombie z2 = (Zombie) zombies.get(j);

					if(z2.hit)
						continue;

					float dx = z2.x - z.x;
					float dy = z2.y - z.y;
					float dist = Math.sqrt(dx*dx + dy*dy);

					if(dist < z.size)
						canMove = false;
				}

				z.draw(canMove);
			}
		}

	}

	void addZombie() {

		if(this.zombies.size() >= this.maxCount)
			return;

		int x = 0;
		int y = 0;
		int r = (int)(Math.random() * 4);

		switch(r)
		{
			case 0:// left
				x = 0 - 50;
				y = halfHeight - (Math.random() * height) + halfHeight;
				break;
			case 1: // top
				x = halfWidth - (Math.random() * width) + halfWidth;
				y = 0 - 50;
				break;
			case 2: // right
				x = width + 50;
				y = halfHeight - (Math.random() * height) + halfHeight;
				break;
			case 3: // bottom
				x = halfWidth - (Math.random() * width) + halfWidth;
				y = height + 50;
				break;
		}

		this.zombies.add(new Zombie(x, y));
	}

}

class Bullet
{
	float x, y, angle;
	int size=5;
	float speed=4;
	boolean alive;

	Bullet(x, y, angle) {
		this.x=x+(cos(x)*(this.speed+2));
		this.y=y+(sin(y)*(this.speed+2));
		this.angle=angle;
		this.alive=true;

		float dx1 = x - nX;
		float dy1 = y - nY;
		float mag = Math.sqrt(dx1*dx1 + dy1*dy1);

		this.dy = dx1 / mag;
		this.dx = dy1 / mag;

		alive = true;
	}

	void move(){

		this.x+=cos(angle)*speed;
		this.y+=sin(angle)*speed;

		if((this.x < 0 || this.x > width)||(this.y < 0 || this.y > height))
			this.alive = false;

		// Hit an zombie?
		int zc=zm.zombies.size()-1;
		for(int i=zc;i>=0;i--) {
			Zombie z = (Zombie) zm.zombies.get(i);

			if(z.hit)
				continue;

			float dx=z.x-this.x;
			float dy=z.y-this.y;
			float dist=sqrt(dx*dx+dy*dy);

			if(dist-(size/2) < z.size/2) {
				z.hit = currentFrame;
				killCount++;
				this.alive = false;
				return;
			}
		}
	}

	void draw() {
		translate(0,0);
		fill( 255, 255, 255 );
		ellipse(x,y,size,size);
	}
}
