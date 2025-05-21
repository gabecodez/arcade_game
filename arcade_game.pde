// Filename: arcade_game.pde
// Author: Gabriel Sullivan
// Purpose: This program is a game where you must fight off enemies by shooting bullets at them.
//          The enemies come in waves.
// Keyboard Commands: A/left arrow for left movement, D/right arrow for right movement, space to shoot
// Images under free use license from Pixabay.

PImage rocket_img; // the main character image
PImage enemy_img; // the main enemy type image
PFont f; // the font

// Classname: Spaceship
// Purpose: The main controlled character (for now without any movement)
class Spaceship {
    float x = 0,y = 0; // position
    float width = 20, height = 20; // size
    int health = 100;
    boolean taking_damage = false;
    int tint_counter = 100;

    // Constructor
    Spaceship(float x, float y, float width, float height, int health) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.health = health;
    }

    // Function name: getHealth
    // Purpose: getter, returns health
    // Input: none
    // Output: int health - the player's health stat
    int getHealth() {
        return health;
    }

    // Function name: display
    // Purpose: displays the object
    // Input: none
    // Output: displays the object to the screen
    void display() {
        pushMatrix();
        noTint();
        imageMode(CENTER);
        image(rocket_img, x, y, width, height);
        popMatrix();
    }

    // Function name: moveLeft
    // Purpose: moves the character left
    // Input: none
    // Output: none
    void moveLeft() {
        if (x >= (0 + (width / 2))) {
            x -= 8;
        }
    }

    // Function name: moveRight
    // Purpose: moves the character right
    // Input: none
    // Output: none
    void moveRight() {
        if (x <= (1040 - (width / 2))) {
            x += 8;
        }
    }
}

// Classname: Enemy
// Purpose: One of the enemies
class Enemy {
    float x = 0,y = 0; // position
    float width = 20, height = 20; // size
    float speed = 2; // how fast the enemy goes down the screen
    int health = 5; // the enemy health
    boolean taking_damage = false; // used for tint
    int tint_counter = 100; // used for tint

    // Constructor
    Enemy(float x, float y, float width, float height, int health, float speed) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.health = health;
        this.speed = speed;
    }

    // Function name: getHealth
    // Purpose: getter, returns health
    // Input: none
    // Output: int health - the player's health stat
    int getHealth() {
        return health;
    }

    // Function name: display
    // Purpose: displays the object
    // Input: none
    // Output: displays the object to the screen
    void display() {
        pushMatrix();
        // handle tint effect
        if (taking_damage && tint_counter > 0) {
            tint(255, 100, 100, 200);
            tint_counter--;
        } else {
            noTint();
        }

        imageMode(CENTER);
        image(enemy_img, x, y, width, height);
        popMatrix();
    }

    // Function name: takeDamage
    // Purpose: takes damage on the character by removing health and doing a visual effect
    // Input: none
    // Output: none
    void takeDamage(int damage_points_taken) {
        health -= damage_points_taken;
        taking_damage = true; // start the tint
        tint_counter = 10; // tint will last for ten frames
    }

    // Function name: move
    // Purpose: moves the character down
    // Input: none
    // Output: none
    void move() {
        y += speed; // move down the screen
    }

    // Function name: pastBottom
    // Purpose: checks if its below the screen
    // Input: none
    // Output: boolean, true if it reaches the bottom, false if not yet
    boolean pastBottom() {
        // If we go a little beyond the bottom
        if (y > 700) { 
            return true;
        } else {
            return false;
        }
    }
}

// Classname: Bullet
// Purpose: A bullet shot from the rocket
class Bullet {
    float x = 0,y = 0; // position
    float r = 5; // size
    int speed = 2; // how fast it goes up the screen

    // Constructor
    Bullet(float x, float y, float r, int speed) {
        this.x = x;
        this.y = y;
        this.r = r;
        this.speed = speed;
    }

    // Function name: display
    // Purpose: displays the object
    // Input: none
    // Output: displays the object to the screen
    void display() {
        pushMatrix();
        // just make a dot
        ellipseMode(CENTER);
        ellipse(x, y, r, r);
        popMatrix();
    }

    // Function name: move
    // Purpose: moves the character down
    // Input: none
    // Output: none
    void move() {
        y -= speed; // move up the screen towards the enemies
    }

    // Function name: pastTop
    // Purpose: checks if its above the screen
    // Input: none
    // Output: boolean, true if it reaches the top, false if not yet
    boolean pastTop() {
        // If we go a little beyond the top
        if (y < -50) { 
            return true;
        } else {
            return false;
        }
    }

    // Function name: intersecting
    // Purpose: checks if the bullet is intersecting with an enemy
    // Input: none
    // Output: boolean, true if these are intersecting, false if not
    boolean intersecting(Enemy e) {
        // Calculate distance
        float distance = dist(x, y, e.x, e.y); 

        // Compare distance to sum of radii
        if (distance < r + e.width) { 
            return true;
        } else {
            return false;
        }
    }
}


Spaceship spaceship; // player
ArrayList<Enemy> enemies = new ArrayList<>(); // enemies going down the screen
ArrayList<Bullet> bullets = new ArrayList<>(); // bullets shot by player

int totalEnemies = 8; // total enemies to render
int totalBullets = 0; // total bullets on screen
int level = 1; // current wave
int score = 0; // player score
boolean gameOver = false; // if they lose

// variables for handling controls without flickering
boolean moveLeftPressed = false;
boolean moveRightPressed = false;
boolean moveUpPressed = false;
boolean moveDownPressed = false;
boolean spacePressed = false;

// handle contols
void keyPressed() {
    if (key == 'a' || key == 'A') moveLeftPressed = true; // move left
    if (key == 'd' || key == 'D') moveRightPressed = true; // move right

    if (key == CODED) {
        if (keyCode == LEFT) moveLeftPressed = true; // move left
        if (keyCode == RIGHT) moveRightPressed = true; // move right
    }
}

void keyReleased() {
    if (key == 'a' || key == 'A') moveLeftPressed = false;
    if (key == 'd' || key == 'D') moveRightPressed = false;

    if (key == CODED) {
        if (keyCode == LEFT) moveLeftPressed = false;
        if (keyCode == RIGHT) moveRightPressed = false;
    }

    // if space pressed shoot a bullet from player position
    if (key == ' ') {
        bullets.add(new Bullet(spaceship.x, spaceship.y - 50, 5, 10));
        totalBullets++;
    }
}

void setup() {
    size(1040, 640); // set the window size
    background(0); // create a white background
    rocket_img = loadImage("rocket.png");
    enemy_img = loadImage("enemy.png");
    spaceship = new Spaceship(520, 580, 100, 180, 100);
    // create the enemies
    for (int i = 0; i < totalEnemies; i++) {
        enemies.add(new Enemy(random(width), random(-500, -50), 50, 50, 20, 0.5)); // randomly place them across the screen
    }

    f = createFont("Arial", 12, true); // set the font
}

void draw() {
    background(0); // render a space black background

    // If the game is over
    if (gameOver) {
        // display game over screen
        textFont(f, 48);
        textAlign(CENTER);
        fill(255);
        text("GAME OVER", width/2, height/2);
        textFont(f, 20);
        text("Final Wave: " + level, width/2, height/2 + 40);
        text("Final Score: " + score, width/2, height/2 + 60);
    } else {
        spaceship.display(); // render player

        // if there are no enemies, increase the wave (the player killed them all)
        if(enemies.isEmpty()) {
            level++;
            totalEnemies += 3;
            // create the enemies
            for (int i = 0; i < totalEnemies; i++) {
                enemies.add(new Enemy(random(width), random(-500, -50), 50, 50, 20, 0.5));
            }
        }

        // Move and display all enemies
        for (int i = enemies.size() - 1; i >= 0; i--) {
            enemies.get(i).move();
            enemies.get(i).display();
            if (enemies.get(i).pastBottom()) {
                gameOver = true;
            } 

            // if a bullet hits an enemy, hurt them
            for (int j = bullets.size() - 1; j >= 0; j--) {
                if (bullets.get(j).intersecting(enemies.get(i))) {
                    enemies.get(i).takeDamage(5);
                    bullets.remove(j);
                    totalBullets--;
                }
            }

            // if the enemy's health is zero, kill them
            if(enemies.get(i).health <= 0) {
                enemies.remove(i);
                score += 1;
            }
        }

        // loop through any bullets and render them
        for (int i = bullets.size() - 1; i >= 0; i--) {
            Bullet b = bullets.get(i);
            b.move();
            b.display();
        
            // Remove bullets that leave the screen
            if (b.pastTop()) {
                    bullets.remove(i);
                    totalBullets--;
            }
        }

        // render HUD
        textFont(f, 14);
        fill(255);
        text("Don't let them reach the bottom!", 10, 20);
        text("Move with arrows/ a+d! Shoot with space!", 10, 40);

        text("Wave: " + level, 300, 20);
        text("Score: " + score, 300, 40);

        // spaceship movement
        if (moveLeftPressed) spaceship.moveLeft();
        if (moveRightPressed) spaceship.moveRight();
    }
}
