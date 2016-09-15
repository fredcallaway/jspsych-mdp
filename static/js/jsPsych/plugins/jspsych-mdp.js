// Generated by CoffeeScript 1.10.0

/*
jspsych-mdp.coffee
Fred Callaway

Plugin for Markov Decision Processes

Documentation: HA!
 */

(function() {
  var KEYCODE_TO_LETTER;

  KEYCODE_TO_LETTER = {
    70: 'F',
    74: 'J',
    75: 'K',
    76: 'L'
  };

  jsPsych.plugins['mdp'] = (function() {
    var plugin, state;
    console.log('defining mdp plugin ');
    plugin = {};
    state = null;
    plugin.trial = function(display_element, trial) {
      var action, after_response, choices, d, end_trial, img, imgs, keyboardListener, ref, setTimeoutHandlers, states, stimuli_html, t1, t2, trial_data;
      states = trial.MDP;
      if (state === null) {
        state = trial.initial_state;
      }
      console.log('mdp trial in state ' + state.id);
      trial_data = null;
      setTimeoutHandlers = [];
      if (state.prompt) {
        display_element.append(state.prompt);
      }
      console.log(Object.keys(state.actions));
      console.log(state.actions.F.img);
      ref = state.actions;
      for (action in ref) {
        d = ref[action];
        console.log(action, d.img);
      }
      imgs = (function() {
        var ref1, results;
        ref1 = state.actions;
        results = [];
        for (action in ref1) {
          img = ref1[action].img;
          results.push("<img class='mdp-stim' id='action-" + action + "' src='" + img + "' alt=''/>");
        }
        return results;
      })();
      stimuli_html = "<div id='jspsych-distributed-imgs'>" + imgs.join('\n') + '<span class="stretch"></span></div>';
      display_element.append(stimuli_html);
      end_trial = function() {
        var i;
        display_element.html('');
        i = 0;
        while (i < setTimeoutHandlers.length) {
          clearTimeout(setTimeoutHandlers[i]);
          i++;
        }
        if (typeof keyboardListener !== 'undefined') {
          jsPsych.pluginAPI.cancelKeyboardResponse(keyboardListener);
        }
        jsPsych.finishTrial(trial_data);
      };
      after_response = function(info) {
        var next_state_id, reward;
        if (trial_data === !null) {
          return;
        }
        trial_data = {
          state: state.id,
          action: KEYCODE_TO_LETTER[info.key],
          rt: info.rt
        };
        action = state.actions[trial_data.action];
        next_state_id = action.transition();
        reward = action.reward();
        state = states[next_state_id];
        trial_data.reward = reward;
        display_element.append($('<div>', {
          id: 'jspsych-mdp-reward',
          html: '<p>' + '$'.repeat(reward) + '</p>'
        }));
        $('.mdp-stim').css('visibility', 'hidden');
        $("#action-" + trial_data.action).css('visibility', 'visible');
        console.log('trial_data ', trial_data);
        setTimeout(end_trial, 2000);
      };
      choices = Object.keys(state.actions);
      keyboardListener = jsPsych.pluginAPI.getKeyboardResponse({
        callback_function: after_response,
        valid_responses: choices,
        rt_method: 'date',
        persist: false,
        allow_held_key: false
      });
      if (trial.timing_stim > 0) {
        t1 = setTimeout((function() {
          $('#jspsych-single-stim-stimulus').css('visibility', 'hidden');
        }), trial.timing_stim);
        setTimeoutHandlers.push(t1);
      }
      if (trial.timing_response > 0) {
        t2 = setTimeout((function() {
          end_trial();
        }), trial.timing_response);
        setTimeoutHandlers.push(t2);
      }
    };
    return plugin;
  })();

}).call(this);
