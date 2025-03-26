package room;

import cartago.Artifact;
import cartago.INTERNAL_OPERATION;
import cartago.OPERATION;
import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.MqttDefaultFilePersistence;

/**
 * A CArtAgO artifact that provides an operation for sending messages to agents
 * with KQML performatives using the dweet.io API
 */
public class MQTTArtifact extends Artifact {

    MqttClient client;
    String broker = "tcp://test.mosquitto.org:1883";
    String clientId; // TODO: Initialize in init method.
    String topic = "was-exercise-6/communication-tibor"; // TODO: change topic name to make it specific to you.
    int qos = 2;

    public void init(String name) {
        // TODO: subscribe to the right topic of the MQTT broker and add observable
        // properties for perceived messages (using a custom MQTTCallack class, and the
        // addMessage internal operation).
        // The name is used for the clientId.
        this.clientId = name;
        try {
            client = new MqttClient(broker, clientId, new MqttDefaultFilePersistence());
            MqttConnectOptions connOpts = new MqttConnectOptions();
            connOpts.setCleanSession(true);
            client.connect(connOpts);
            client.subscribe(topic, qos);
            client.setCallback(new MQTTCallback());
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }

    @OPERATION
    public void sendMsg(String agent, String performative, String content) {
        // TODO: complete operation to send messages
        try {
            String message = agent + "," + performative + "," + content;
            MqttMessage mqttMessage = new MqttMessage(message.getBytes());
            mqttMessage.setQos(qos);
            client.publish(topic, mqttMessage);
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }

    @INTERNAL_OPERATION
    public void addMessage(String agent, String performative, String content) {
        // TODO: complete to add a new observable property.
        defineObsProperty("message", agent, performative, content);
    }

    // TODO: create a custom callback class from MQTTCallack to process received
    // messages
    private class MQTTCallback implements MqttCallback {

        @Override
        public void connectionLost(Throwable cause) {
            // Handle connection lost
        }

        @Override
        public void messageArrived(String topic, MqttMessage message) throws Exception {
            String[] parts = new String(message.getPayload()).split(",");
            if (parts.length == 3) {
                execInternalOp("addMessage", parts[0], parts[1], parts[2]);
            }
        }

        @Override
        public void deliveryComplete(IMqttDeliveryToken token) {
            // Handle delivery complete
        }
    }

}
