var detents_prop = 'controls/engines/detents/';
var athr = '/flight-management/control/a-thrust';
var athr_lever_pos_l = '/flight-management/control/a-thr-lever-pos[0]';
var athr_lever_pos_r = '/flight-management/control/a-thr-lever-pos[1]';
var left_lever_pos = 'controls/engines/engine[0]/throttle-pos';
var right_lever_pos = 'controls/engines/engine[1]/throttle-pos';
var DETENT_SOUND = 7;
var ENGINE_COUNT = 2;

var detents = {
    REV: getprop(detents_prop~ 'rev'),
    IDLE: getprop(detents_prop~ 'idle'),
    CLB: getprop(detents_prop~ 'clb'),
    FLEX: getprop(detents_prop~ 'flex'),
    TOGA: getprop(detents_prop~ 'toga')
};

setprop(athr_lever_pos_l, detents.CLB);
setprop(athr_lever_pos_r, detents.CLB);
setprop(left_lever_pos, 0);
setprop(right_lever_pos, 0);

for(var idx = 0; idx < ENGINE_COUNT; idx = idx + 1){
    var i = idx;
    setlistener('controls/engines/engine['~i~']/throttle-pos', func(node){
        var left_pos = getprop(left_lever_pos);
        var right_pos = getprop(right_lever_pos);
        var max_pos = (right_pos > left_pos ? right_pos : left_pos);
        var self_pos = node.getValue();
        if(self_pos == nil) self_pos = 0;
        var athr_status = getprop(athr);
        if(max_pos >= detents.FLEX){
            if(athr_status != 'armed'){
                setprop(athr, 'armed');
            }
        }
        elsif(max_pos <= detents.IDLE){
            if(athr_status != 'off'){
                setprop(athr, 'off');
            }
        } 
        elsif(max_pos > 0 and max_pos <= detents.CLB) {
            if(getprop(athr) == 'armed'){
                setprop(athr, 'eng');
            }
        }
        foreach(var k; keys(detents)){
            if(int(self_pos * 100) == int(detents[k] * 100)){
                utils.clickSound(DETENT_SOUND);
                break;
            }       
        }
    }, 0, 0);
}

controls.incThrottle = func {
    var i = 0;
    var rev = getprop('controls/engines/engine/reverser');
    for(i = 0; i < ENGINE_COUNT; i = i + 1){
        var cur_throttle = getprop('controls/engines/engine['~i~']/throttle-pos');
        if(cur_throttle == nil) cur_throttle = 0;
        cur_throttle += arg[0];
        var min = (rev ? -0.63 : 0.0);
        var max = (rev ? 0.0 : 1.0);
        setprop('controls/engines/engine['~i~']/throttle-pos',
                cur_throttle < min ? min : cur_throttle > max ? max : cur_throttle
               );
    }
}
