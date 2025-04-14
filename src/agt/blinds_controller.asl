// blinds controller agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds (was:Blinds)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/blinds.ttl").

// the agent initially believes that the blinds are "lowered"
blinds("lowered").

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:Blinds is located at Url
 * Body: greets the user
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", Url) <-
    .print("Hello world");
    makeArtifact("blinds", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], ArtId);
    ?mqttReady.

/*
* Plan for looking up created MQTT artifact by personal assistant.
* If not ready yet, wait for 50ms and retry.
* According to: https://www.emse.fr/~boissier/enseignement/maop13/courses/cartagoByExamples.pdf (p.18)
*/
+?mqttReady : true <-
    lookupArtifact("mqttArtifact", MQTTArtifactId);
    focus(MQTTArtifactId).
-?mqttReady : true <-
    .wait(50);
    ?mqttReady.

/* Plan for reacting to received messages
 * Triggering event: addition of observable property message
 * Context: true (the plan is always applicable)
 * Body: prints the received message
*/
@react_to_message
+message(Sender, Performative, Content) : true <-
    .print("Received message from ", Sender, " with performative: ", Performative, " and content: ", Content).

/*
* Plan for raising the blinds
* Triggering event: addition of goal !raise_blinds
* Context: the blinds are "lowered"
* Body: raises the blinds
*/
@raise_blinds_plan
+!raise_blinds : blinds("lowered") <-
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState", ["raised"]);
    -+blinds("raised").

/*
* Plan for lowering the blinds
* Triggering event: addition of goal !lower_blinds
* Context: the blinds are "raised"
* Body: lowers the blinds
*/
@lower_blinds_plan
+!lower_blinds : blinds("raised") <-
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState", ["lowered"]);
    -+blinds("lowered").


/*
* Plan for reacting to the addition of blinds state
* Triggering event: addition of observable property blinds
* Context: true (the plan is always applicable)
* Body: prints the blinds state and sends message to personal assistant
*/
@blinds_plan
+blinds(State) : true <-
    .print("Blinds ", State);
    .send(personal_assistant, tell, blinds(State)).

/*
* Plan for reacting to the addition of a goal to increase illuminance
*/
@cfp_increase_illuminance_plan
+!cfp(increase_illuminance)[source(Sender)] : true <-
    if (blinds("lowered")) {
        .send(Sender, tell, propose(raise_blinds));
    } else {
        .send(Sender, tell, refuse(increase_illuminance));
    }.

@accept_raise_blinds_plan
+acceptProposal(raise_blinds)[source(Sender)] : true <-
    !raise_blinds;
    .send(Sender, tell, inform_done(raise_blinds)).

@refuse_raise_blinds_plan
+rejectProposal(raise_blinds)[source(Sender)] : true <-
    .print("Proposal to raise the blinds refused by ", Sender).

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }