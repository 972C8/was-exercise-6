// personal assistant agent

// Use jason or mqtt for broadcasting
// Replace jason with mqtt for mqtt broadcasting
broadcast(jason). 

natural_light(0).
artificial_light(1).

best_option(Number) :- Number = 0.

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: true (the plan is always applicable)
 * Body: greets the user
*/
@start_plan
+!start : true <-
    .print("Hello world");
    !mqttCreate.

/*
* Plan for creating MQTT artifact. Looked up by blinds_controller and lights_controller.
*/
+!mqttCreate : true <-
    makeArtifact("mqttArtifact", "room.MQTTArtifact", ["client-id-tibor"], MQTTArtifactId);
    focus(MQTTArtifactId);
    !send_message("personal_assistant", "tell", "Personal assistant is ready and using MQTT.").

/* Plan for reacting to received messages
 * Triggering event: addition of observable property message
 * Context: true (the plan is always applicable)
 * Body: prints the received message
*/
@react_to_message
+message(Sender, Performative, Content) : true <-
    .print("Received message from ", Sender, " with performative: ", Performative, " and content: ", Content).

/* Plan for sending an MQTT message
 * Triggering event: addition of goal !send_message(Sender, Performative, Content)
 * Context: true (the plan is always applicable)
 * Body: sends an MQTT message
*/
@send_message_plan
+!send_message(Sender, Performative, Content) : true <-
    sendMsg(Sender, Performative, Content).

//Task 4.1 + 4.2
@upcoming_event_now_asleep_plan
+upcoming_event("now") : owner_state("asleep") <-
    !start_wake_up_routine.

@upcoming_event_now_awake_plan
+upcoming_event("now") : owner_state("awake") <-
    .print("Enjoy your event").

@owner_state_awake_upcoming_event_now_plan
+owner_state("awake") : upcoming_event("now") <-
    .print("Enjoy your event").

@owner_state_asleep_upcoming_event_now_plan
+owner_state("asleep") : upcoming_event("now") <-
    !start_wake_up_routine.

// //Task 4.3
@start_wake_up_routine_plan
+!start_wake_up_routine : true <-
    .print("Starting wake-up routine");
    .abolish(propose(_));
    .abolish(refuse(_));
    -+bidding_status(true);
    // Broadcast based on the selected method
    if (broadcast(jason)) {
        .print("Broadcasting via jason");
        .broadcast(achieve, cfp(increase_illuminance));
    } elif (broadcast(mqtt)) {
        .print("Broadcasting via mqtt");
        !send_message("personal_assistant", "tell", "increase_illuminance");
    } else {
        .print("Broadcasting method unknown");
    }
    .print("Awaiting bids");
    .wait(2000); // Wait 2 seconds for bids to arrive
    -+bidding_status(false);
    .print("Bidding closed");
    !check_cfp_proposals.

@cfp_propose_plan
+propose(Action)[source(Sender)] : bidding_status(true) <-
    .print("Received a proposal from ", Sender, " to ", Action).

@cfp_refuse_plan
+refuse(Action)[source(Sender)] : bidding_status(true) <-
    .print("Received a refusal from ", Sender, " to ", Action).

/*
* Plan for checking the proposals received
* Triggering event: addition of goal !check_cfp_proposals
* Context: true (the plan is always applicable)
* Body: checks the proposals received and sends accept or reject messages
*/
@check_cfp_proposals_plan
+!check_cfp_proposals : true <-
    .count(propose(Action)[source(Sender)], X);
    if (X > 0) {
        .findall([Action, Sender], propose(Action)[source(Sender)], ListOfProposals);
        .print("Proposals received: ", ListOfProposals);
        .length(ListOfProposals, L);
        -+counter(0);
        -+action_performed(false);
        while (counter(Counter) & Counter < L) {
            .nth(Counter, ListOfProposals, [Action, Sender]);
            if (action_performed(Performed) & Performed = false & Action = turn_on_lights & artificial_light(Number) & best_option(Number)) {
                .print(Action, " is the best option");
                -+natural_light(0);
                -+artificial_light(1);
                .send(Sender, tell, acceptProposal(Action));
                -+action_performed(true);
                .abolish(owner_state(_));
            } elif (action_performed(Performed) & Performed = false & Action = raise_blinds & natural_light(Number) & best_option(Number)) {
                .print(Action, " is the best option");
                -+natural_light(1);
                -+artificial_light(0);
                .send(Sender, tell, acceptProposal(Action));
                -+action_performed(true);
                .abolish(owner_state(_));
            } else {
                .print(Action, " is not the best option");
                .send(Sender, tell, rejectProposal(Action));
            }
            -+counter(Counter + 1);
        }
    } else {
        // Task 4.4
        .print("Asking user's friend to wake them up.");
        !send_message("personal_assistant", "tell", "Asking user's friend to wake them up.");
    }.

@inform_done_plan
+inform_done(Action) : true <-
    .print("The following action has been completed: ", Action);
    .abolish(inform_done(Action)).

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }