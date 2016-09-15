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



MDP = do ->

  weighted_sample = (xs, ps) ->
    # returns xs[i] with probability ps[i]
    thresh = Math.random()
    acc = 0
    for i in [0..xs.length]
      acc += ps[i]
      if acc > thresh
        return xs[i]

  cycle = (opts...) ->
    # ABC -> ABCABCABC
    i = -1
    ->
      i += 1
      opts[i % opts.length]

  increasing = (start, step) ->
    x = start - step
    ->
      x += step
      x

  MDP =
    circle:
      id: 'circle'
      actions:
        F: # action name is the key that takes the action
          img: 'static/images/blue.png'
          # transition and reward are functions
          transition: -> weighted_sample(['circle', 'square'], [0.8, 0.2])
          reward: -> 1
        J:
          img: 'static/images/orange.png'
          transition: -> weighted_sample(['circle', 'square'], [0.2, 0.8])
          reward: -> 0

    square:
      id: 'square'
      actions:
        F:
          img: 'static/images/red.png'
          transition: -> weighted_sample(['square', 'final'], [0, 1])
          reward: -> 2
        J:
          img: 'static/images/green.png'
          transition: cycle('square', 'circle')
          reward: increasing(3, 2)

    final:
      id: 'final'
      final: true

  return MDP

initial_state = MDP['circle']



mdp_block =
  timeline: [type: 'mdp', MDP: MDP, initial_state: initial_state]
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
  # instructions_block
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
