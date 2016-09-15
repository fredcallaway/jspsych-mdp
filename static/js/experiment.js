// Generated by CoffeeScript 1.10.0

/*
experiment.coffee
Fred Callaway

Demonstrates the jsych-mdp plugin
 */

(function() {
  var add_trial_data, cycle, debrief_block, experiment_blocks, getSubjectData, instructions_block, md_to_html, mdp_block, psiturk, states, weighted_sample, welcome_block,
    slice = [].slice;

  psiturk = new PsiTurk(uniqueId, adServerLoc, mode);

  add_trial_data = jsPsych.data.addDataToLastTrial;

  md_to_html = (function() {
    var converter;
    converter = new showdown.Converter();
    return function(txt) {
      return converter.makeHtml(txt);
    };
  })();

  welcome_block = {
    type: "text",
    text: md_to_html('#MDP demonstration')
  };

  instructions_block = {
    type: "text",
    text: md_to_html("You will see **shapes** and push **buttons**, `F` and `J` mostly.\n\n*It's going to be great*!"),
    timing_post_trial: 500
  };

  weighted_sample = function(xs, ps) {
    var acc, i, j, ref, thresh;
    thresh = Math.random();
    console.log(thresh);
    acc = 0;
    for (i = j = 0, ref = xs.length; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
      console.log('acc', acc);
      acc += ps[i];
      if (acc > thresh) {
        return xs[i];
      }
    }
  };

  cycle = function() {
    var i, opts;
    opts = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    i = -1;
    return function() {
      i += 1;
      return opts[i % opts.length];
    };
  };

  states = {
    circle: {
      id: 'circle',
      stimuli: ['static/images/blue.png', 'static/images/orange.png'],
      actions: {
        F: function() {
          return weighted_sample(['circle', 'square'], [0.8, 0.2]);
        },
        J: function() {
          return weighted_sample(['circle', 'square'], [0.2, 0.8]);
        }
      }
    },
    square: {
      id: 'square',
      stimuli: ['static/images/red.png', 'static/images/green.png'],
      actions: {
        F: function() {
          return 'square';
        },
        J: cycle('circle', 'square')
      }
    }
  };

  mdp_block = {
    timeline: [
      {
        type: 'mdp',
        states: states,
        start: states['circle']
      }
    ],
    loop_function: function(data) {
      return !data[0].done;
    }
  };

  debrief_block = {
    type: 'text',
    text: function() {
      var subject_data;
      subject_data = getSubjectData();
      return '<p>You responded correctly on ' + subject_data.accuracy + '% of ' + 'the trials.</p> <p>Your average response time was <strong>' + subject_data.rt + 'ms</strong>. Press any key to complete the ' + 'experiment. Thank you!</p>';
    }
  };

  getSubjectData = function() {
    var correct_rt_count, correct_trial_count, i, sum_rt, trials;
    trials = jsPsych.data.getTrialsOfType('single-stim');
    sum_rt = 0;
    correct_trial_count = 0;
    correct_rt_count = 0;
    i = 0;
    while (i < trials.length) {
      if (trials[i].correct === true) {
        correct_trial_count++;
        if (trials[i].rt > -1) {
          sum_rt += trials[i].rt;
          correct_rt_count++;
        }
      }
      i++;
    }
    return {
      rt: Math.floor(sum_rt / correct_rt_count),
      accuracy: Math.floor(correct_trial_count / trials.length * 100)
    };
  };

  experiment_blocks = [welcome_block, instructions_block, mdp_block];

  console.log('initialze jsPsych');

  jsPsych.init({
    display_element: $('#jspsych-target'),
    timeline: experiment_blocks,
    on_finish: function() {
      jsPsych.data.displayData();
    }
  });

}).call(this);
