###
experiment.coffee
Fred Callaway

Demonstrates the jsych-mdp plugin

###


# coffeelint: disable=max_line_length, indentation

psiturk = new PsiTurk uniqueId, adServerLoc, mode
add_trial_data = jsPsych.data.addDataToLastTrial

# $.getScript('/static/lib/jstat-min.js')
# jstat = this.jStat

md_to_html = do ->
  converter = new showdown.Converter()
  (txt) -> converter.makeHtml(txt)

welcome_block =
  type: "text"
  text: md_to_html('#MDP demonstration')

instructions_block =
  type: "text"
  text: md_to_html("""
  You will see **shapes** and push **buttons**, `F` and `J` mostly.

  *It's going to be great*!
  """)
  timing_post_trial: 500


weighted_sample = (xs, ps) ->
  # returns xs[i] with probability ps[i]
  thresh = Math.random()
  console.log(thresh)
  acc = 0
  for i in [0..xs.length]
    console.log('acc', acc)
    acc += ps[i]
    if acc > thresh
      return xs[i]

cycle = (opts...) ->
  # ABC -> ABCABCABC
  i = -1
  ->
    i+=1
    opts[i % opts.length]

states =
  circle:
    id: 'circle'
    stimuli: ['static/images/blue.png', 'static/images/orange.png']
    actions:
      F: -> weighted_sample(['circle', 'square'], [0.8, 0.2])
      J: -> weighted_sample(['circle', 'square'], [0.2, 0.8])
      
  square:
    id: 'square'
    stimuli: ['static/images/red.png', 'static/images/green.png']
    actions:
      F: -> 'square'
      J: cycle('circle', 'square')
  


mdp_block =
  timeline: [type: 'mdp', states: states, start: states['circle']]
  loop_function: (data) -> not data[0].done


debrief_block =
  type: 'text'
  text: ->
    subject_data = getSubjectData()
    '<p>You responded correctly on ' + subject_data.accuracy + '% of ' + 'the trials.</p>
      <p>Your average response time was <strong>' + subject_data.rt + 'ms</strong>. Press any key to complete the ' + 'experiment. Thank you!</p>'

getSubjectData = ->
  trials = jsPsych.data.getTrialsOfType('single-stim')
  sum_rt = 0
  correct_trial_count = 0
  correct_rt_count = 0
  i = 0
  while i < trials.length
    if trials[i].correct == true
      correct_trial_count++
      if trials[i].rt > -1
        sum_rt += trials[i].rt
        correct_rt_count++
    i++
  {
  rt: Math.floor(sum_rt / correct_rt_count)
  accuracy: Math.floor(correct_trial_count / trials.length * 100)
  }

experiment_blocks = [
  welcome_block
  instructions_block
  # test_block
  mdp_block
  # debrief_block
]

console.log 'initialze jsPsych'
jsPsych.init
  display_element: $('#jspsych-target')
  timeline: experiment_blocks
  # show_progress_bar: true
  on_finish: ->
    jsPsych.data.displayData()
    return

# on_data_update: (data) ->
#   console.log(data)
#   #psiturk.recordTrialData(data)
#   return
