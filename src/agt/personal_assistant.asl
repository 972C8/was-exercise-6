// personal assistant agent

broadcast(jason).

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

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }