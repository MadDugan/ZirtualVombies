// Global variables
float radius = 50.0;
int halfWidth, halfHeight;
int X, Y;
int nX, nY;
int delay = 16;
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

	player = new Player(halfWidth, halfHeight);
	zm = new ZombieManager(150);
	
	for(int i=0;i<20;i++) {
		zm.addZombie();
	}
}

// Main draw loop
void draw(){

	// Fill canvas grey
	background( 100 );
	
	player.draw();

	// add zombies periodically based on difficulty
	if(!(frameCount % difficulty[currentDifficulty])){
		zm.addZombie();
	}
	
	// increase difficulty every 1000 frames
	if(!(frameCount % 1000)) {
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
				if(!(frameCount % 4))
					player.fire();
			}
			
			this.radius = this.radius + (sin( frameCount / 4 ) / 2);

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
			// dead
			textSize(50);
			fill( 0, 121, 184 );
			text("GAME OVER", (width/2)-150, height/2-85);			
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
		}
	}
}

class Zombie
{
	float x, y, angle, radius;
	float size = 35;
	boolean alive;

	Zombie(int x, int y) {
		this.x = x;
		this.y = y;
		this.radius = 50.0;
		alive = true;
		this.rand = Math.random() * 100;
	}

	// always face player.
	void draw(boolean canMove) {

		this.radius = this.radius + (sin( (this.rand + frameCount) / 3 ) / 2);

		float dx = player.x - this.x;
		float dy = player.y - this.y;
		this.angle = atan2(dy, dx);
		
		if(canMove) {
			mag = Math.sqrt(dx*dx + dy*dy);

			this.x += (0.75) * ((player.x - this.x) / mag);
			this.y += (0.75) * ((player.y - this.y) / mag);
		}
		
		pushMatrix();
		translate(this.x, this.y);
		rotate(this.angle);
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
		for(int i=zc;i>=0;i--){ 
			Zombie z = (Zombie) zm.zombies.get(i);

			float dx=z.x-this.x;
			float dy=z.y-this.y;
			float dist=sqrt(dx*dx+dy*dy);

			if(dist-(size/2) < z.size/2){

				zm.zombies.remove(i);
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


/*
// Simple Vector3D Class
public class Vector3D {
  public float x;
  public float y;
  public float z;

  Vector3D(float x_, float y_, float z_) {
    x = x_; y = y_; z = z_;
  }

  Vector3D(float x_, float y_) {
    x = x_; y = y_; z = 0f;
  }

  Vector3D() {
    x = 0f; y = 0f; z = 0f;
  }

  void setX(float x_) {
    x = x_;
  }

  void setY(float y_) {
    y = y_;
  }

  void setZ(float z_) {
    z = z_;
  }

  void setXY(float x_, float y_) {
    x = x_;
    y = y_;
  }

  void setXYZ(float x_, float y_, float z_) {
    x = x_;
    y = y_;
    z = z_;
  }

  void setXYZ(Vector3D v) {
    x = v.x;
    y = v.y;
    z = v.z;
  }

  public float magnitude() {
    return (float) Math.sqrt(x*x + y*y + z*z);
  }

  public Vector3D copy() {
    return new Vector3D(x,y,z);
  }

  public Vector3D copy(Vector3D v) {
    return new Vector3D(v.x, v.y,v.z);
  }

  public void add(Vector3D v) {
    x += v.x;
    y += v.y;
    z += v.z;
  }

  public void sub(Vector3D v) {
    x -= v.x;
    y -= v.y;
    z -= v.z;
  }

  public void mult(float n) {
    x *= n;
    y *= n;
    z *= n;
  }

  public void div(float n) {
    x /= n;
    y /= n;
    z /= n;
  }

  public void normalize() {
    float m = magnitude();
    if (m > 0) {
       div(m);
    }
  }

  public void limit(float max) {
    if (magnitude() > max) {
      normalize();
      mult(max);
    }
  }

  public float heading2D() {
    float angle = (float) Math.atan2(-y, x);
    return -1*angle;
  }

  public Vector3D add(Vector3D v1, Vector3D v2) {
    Vector3D v = new Vector3D(v1.x + v2.x,v1.y + v2.y, v1.z + v2.z);
    return v;
  }

  public Vector3D sub(Vector3D v1, Vector3D v2) {
    Vector3D v = new Vector3D(v1.x - v2.x,v1.y - v2.y,v1.z - v2.z);
    return v;
  }

  public Vector3D div(Vector3D v1, float n) {
    Vector3D v = new Vector3D(v1.x/n,v1.y/n,v1.z/n);
    return v;
  }

  public Vector3D mult(Vector3D v1, float n) {
    Vector3D v = new Vector3D(v1.x*n,v1.y*n,v1.z*n);
    return v;
  }

  public float distance (Vector3D v1, Vector3D v2) {

    float dx = v1.x - v2.x;
    float dy = v1.y - v2.y;
    float dz = v1.z - v2.z;

    return (float) Math.sqrt(dx*dx + dy*dy + dz*dz);
  }
}
*/