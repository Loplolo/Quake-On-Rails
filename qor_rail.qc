.entity cart_target;
.float  cart_speed;

.float  wait_time;
.float  movetime;

.string cart_start;

.string look_target_name;
.entity look_target; 
.vector sdir;
.float  current_score;

.float angle;
void() RideRail = 
{
    if (!self.cart_target) return;
	
	// cart movement flags and attributes
    self.movetype = MOVETYPE_FLY;
    self.velocity = '0 0 0';
    self.flags = not(self.flags, FL_ONGROUND);
	self.fixangle = TRUE; 

    local vector dir = self.cart_target.origin - self.origin;
    local float dist = vlen(dir);
    local float travel = self.cart_speed * frametime;
    local float is_moving = TRUE;

    if (dist <= travel || dist < 1) 
    {
        setorigin(self, self.cart_target.origin);

        // if wait is -1 it stops until triggered
		if (self.cart_target.wait == -1 && self.wait_time != -2) 
			{
				self.wait_time = -1;
				is_moving = FALSE;
			}
        else if (self.cart_target.wait > 0) 
        {
            if (self.wait_time == 0) {
                self.wait_time = time + self.cart_target.wait;
                is_moving = FALSE;
            } else if (time < self.wait_time) {
                is_moving = FALSE; 
            }
        }
        
        // get next node if not waiting
        if (is_moving) 
        {
            self.wait_time = 0;
            
            entity next_node = find(world, targetname, self.cart_target.target);
            
            if (next_node) {
                self.cart_target = next_node;
                dir = self.cart_target.origin - self.origin;
                
                if (next_node.look_target_name != "") {
                    self.look_target = find(world, targetname, next_node.look_target_name);
                } else {
                    self.look_target = world;
                }

                if (self.cart_target.movetime > 0) {
                    self.cart_speed = vlen(dir) / self.cart_target.movetime;
                } else {
                    self.cart_speed = (self.cart_target.speed > 0) ? self.cart_target.speed : 300;
                }
            } else {
                // end of the rail
                self.cart_target = world;
                self.look_target = world;
                //self.movetype = MOVETYPE_WALK;
                return; 
            }
        }
    } 
    else 
    {
        setorigin(self, self.origin + normalize(dir) * travel);
    }

    vector target_angle;   
    if (self.look_target) 
    {
        // specify where to look with an entity
        // can be used to lock the view to a monster/moving entity
        local vector look_dir = self.look_target.origin - self.origin;
        target_angle = vectoangles(normalize(look_dir));
    } 
    else 
    {
		// look straight in the moving direction
        if (vlen(dir) > 0)
            target_angle = vectoangles(normalize(dir));
        else
            target_angle = self.angles;
    }
    
    local vector diff;
    
    // yaw interpolation
    diff_y = target_angle_y - self.angles_y;
    while (diff_y > 180) diff_y -= 360;
    while (diff_y < -180) diff_y += 360;

    // pitch interpolation
    diff_x = target_angle_x - self.angles_x;
    while (diff_x > 180) diff_x -= 360;
    while (diff_x < -180) diff_x += 360;

    self.angles_y += diff_y * 10 * frametime;
    self.angles_x += diff_x * 10 * frametime; 
    self.angles_z = 0;
    
};

void(entity plr, entity first_corner) player_first_corner_select =
{
    plr.wait_time = 0;
    plr.cart_target = first_corner;
    
    if (first_corner.look_target_name != "") {
        plr.look_target = find(world, targetname, first_corner.look_target_name);
    } else {
        plr.look_target = world;
    }

    local vector dir = first_corner.origin - plr.origin;
    if (first_corner.movetime > 0) {
        plr.cart_speed = vlen(dir) / first_corner.movetime;
    } else {
        plr.cart_speed = (first_corner.speed > 0) ? first_corner.speed : 300;
    }
};

void() cart_corner_use =
{
    local entity p = find(world, classname, "player");
    if (p) p.wait_time = -2; // resume movement on use
};

void() cart_corner = 
{
    self.use = cart_corner_use; 
    if (!self.speed && !self.movetime) {
        self.speed = 300; 
    }
};

void() cart_lookat_use = 
{
	
    local entity p = find(world, classname, "player");
    if (!p) return;

    if (self.target != "") 
    {
        local entity target_name = find(world, targetname, self.target);
        if (target_name) {
            p.look_target = target_name;
        } else {
            dprint("cart_target_lookat: target not found\n");
        }
    } 
    else 
    {
        p.look_target = world; 
    }
};

void() cart_target_lookat = 
{
    self.use = cart_lookat_use;
};

// Engine cmd hook
void(string cmd) SV_ParseClientCommand =
{
    tokenize(cmd);

    if (argv(0) == "sdir")
    {
        self.sdir = [stof(argv(1)), stof(argv(2)), stof(argv(3))];
        return; 
    }
    
    clientcommand(self, cmd);
};
