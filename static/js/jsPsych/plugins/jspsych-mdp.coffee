###
jspsych-mdp.coffee
Fred Callaway

Plugin for Markov Decision Processes

Documentation: HA!
###

# coffeelint: disable=max_line_length

KEYCODE_TO_LETTER =
  70: 'F'
  74: 'J'
  75: 'K'
  76: 'L'

jsPsych.plugins['mdp'] = do ->
  console.log 'defining mdp plugin '
  plugin = {}

  state = null

  plugin.trial = (display_element, trial) ->
    # Use existing state or initialize new state.
    states = trial.MDP
    if state is null
      state = trial.initial_state
    console.log 'mdp trial in state ' + state.id

    trial_data = null

    # if any trial variables are functions
    # this evaluates the function and replaces
    # it with the output of the function
    # trial = jsPsych.pluginAPI.evaluateFunctionParameters(trial)


    # this array holds handlers from setTimeout calls
    # that need to be cleared if the trial ends early
    setTimeoutHandlers = []


    # # set default values for the parameters
    # trial.timing_stim = trial.timing_stim or -1
    # trial.timing_response = trial.timing_response or -1
    # trial.is_html = trial.is_html or false
    # trial.prompt = trial.prompt or ''


    #show prompt if there is one
    if state.prompt
      display_element.append state.prompt

    # display action images
    imgs = for action, {img: img} of state.actions
      "<img class='mdp-stim' id='action-#{action}' src='#{img}' alt=''/>"

    stimuli_html =
      "<div id='jspsych-distributed-imgs'>" +
      imgs.join('\n') +
      '<span class="stretch"></span></div>'
    display_element.append stimuli_html


    end_trial = ->
      # clear the display
      display_element.html ''

      # kill any remaining setTimeout handlers
      i = 0
      while i < setTimeoutHandlers.length
        clearTimeout setTimeoutHandlers[i]
        i++

      # kill keyboard listeners
      if typeof keyboardListener != 'undefined'
        jsPsych.pluginAPI.cancelKeyboardResponse keyboardListener

      if trial_data.done
        display_element.html "<div class=big-text>Nice job!</div>"

      # move on to the next trial
      jsPsych.finishTrial trial_data
      return


    after_response = (info) ->
      # only accept one response
      return if trial_data is not null
      
      trial_data =
        state: state.id
        action: KEYCODE_TO_LETTER[info.key]
        rt: info.rt

      # update state and assign reward
      action = state.actions[trial_data.action]
      next_state_id = action.transition()
      reward = action.reward()
      state = states[next_state_id]
      trial_data.reward = reward

      if state.final
        trial_data.done = true

      # display reward
      display_element.append $('<div>',
        id: 'jspsych-mdp-reward'
        html: '$'.repeat(reward) or 'X'
      )

      # hide the images of the other actions
      $('.mdp-stim').css 'visibility', 'hidden'
      $("#action-#{trial_data.action}").css 'visibility', 'visible'

      console.log 'trial_data ', trial_data
      setTimeout end_trial, 2000
      return

    # start the response listener
    choices = Object.keys(state.actions)
    keyboardListener = jsPsych.pluginAPI.getKeyboardResponse(
      callback_function: after_response
      valid_responses: choices
      rt_method: 'date'
      persist: false
      allow_held_key: false)

    # hide image if timing is set
    if trial.timing_stim > 0
      t1 = setTimeout((->
        $('#jspsych-single-stim-stimulus').css 'visibility', 'hidden'
        return
      ), trial.timing_stim)
      setTimeoutHandlers.push t1
    # end trial if time limit is set
    if trial.timing_response > 0
      t2 = setTimeout((->
        end_trial()
        return
      ), trial.timing_response)
      setTimeoutHandlers.push t2
    return

  plugin

# ---
# generated by js2coffee 2.2.0