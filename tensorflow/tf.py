import os
import cv2
import tensorflow as tf
from tensorflow import keras
import numpy as np
from tqdm import tqdm
from random import shuffle
import matplotlib.pyplot as plt
import datetime
from tensorflow.keras.layers import Dense, Conv2D, Flatten, Dropout, MaxPooling2D
from tensorflow.keras.models import Sequential
from tensorflow.keras import regularizers, layers, models
from tensorflow.python.tools import freeze_graph
from tensorflow.python.framework.convert_to_constants import convert_variables_to_constants_v2



def label_img(img):
    word_label = img.split('.')[0]
    if word_label == 'othors':
        return 0
    elif word_label == 'dracaena_lemon_lime':
        return 1
    elif word_label == 'peace_lily':
        return 2
    elif word_label == 'pothos':
        return 3
    elif word_label == 'snake_plant':
        return 4
    elif word_label == 'croton':
        return 5
    else:
        print("+=============================+==================================================+=========")
        print(word_label)
def label_img_new(img):
    word_label = img.split('.')[0]
    if word_label == 'othors':
        return 0
    elif word_label == 'dracaena_lemon_lime':
        return 1
    elif word_label == 'peace_lily':
        return 2
    elif word_label == 'golden_pothos':
        return 3
    elif word_label == 'Laurentii':
        return 4
    elif word_label == 'croton':
        return 5
    else:
        print("+=============================+==================================================+=========")
        print(word_label)


def create_training_data(TRAIN_DIR, IMG_SIZE,FILE_NAME):
    training_data = []
    for img in tqdm(os.listdir(TRAIN_DIR)):
        label = label_img_new(img)
        path = os.path.join(TRAIN_DIR, img)
        img = cv2.resize(cv2.imread(path, cv2.IMREAD_COLOR), (IMG_SIZE, IMG_SIZE))
        training_data.append([np.array(img), np.array(label)])
    shuffle(training_data)
    np.save(FILE_NAME+str(IMAGE_SIZE)+".npy", training_data)
    return training_data



def buildModel_0(IMAGE_SIZE):
    # model architecture
    model = models.Sequential()
    model.add(layers.Conv2D(32 , (3, 3), activation='relu', kernel_regularizer=regularizers.l2(0.001), input_shape=(IMAGE_SIZE, IMAGE_SIZE, 3)))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Dropout(0.2))
    model.add(layers.Conv2D(32, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Dropout(0.2))
    model.add(layers.Conv2D(32, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Dropout(0.2))
    model.add(layers.Conv2D(32, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.Flatten())
    model.add(layers.Dense(32, kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.Dropout(0.2))
    model.add(layers.Dense(6, activation='softmax'))
    model.compile( optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
                  loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
                  metrics=['accuracy'])
    return model

def buildModel_1(IMAGE_SIZE):
    # model architecture
    model = models.Sequential()
    model.add(layers.Conv2D(32 , (3, 3), activation='relu', kernel_regularizer=regularizers.l2(0.001), input_shape=(IMAGE_SIZE, IMAGE_SIZE, 3)))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Dropout(0.35))
    model.add(layers.Conv2D(32, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Dropout(0.35))
    model.add(layers.Conv2D(32, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Dropout(0.35))
    model.add(layers.Conv2D(32, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Dropout(0.35))
    model.add(layers.Conv2D(32, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Dropout(0.35))
    model.add(layers.Conv2D(32, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.Flatten())
    model.add(layers.Dense(32, kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.Dropout(0.35))
    model.add(layers.Dense(6, activation='softmax'))
    model.compile( optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
                  loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
                  metrics=['accuracy'])
    return model

def buildModel_2(IMAGE_SIZE):
    # model architecture
    model = models.Sequential()
    model.add(layers.Conv2D(32 , (3, 3), activation='relu', kernel_regularizer=regularizers.l2(0.001), input_shape=(IMAGE_SIZE, IMAGE_SIZE, 3)))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Dropout(0.3))
    model.add(layers.Conv2D(42, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Dropout(0.3))
    model.add(layers.Conv2D(42, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.Dropout(0.3))
    model.add(layers.Conv2D(42, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Dropout(0.3))
    model.add(layers.Conv2D(42, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.Flatten())
    model.add(layers.Dense(42, kernel_regularizer=regularizers.l2(0.001), activation='softmax'))
    model.add(layers.Dropout(0.3))
    model.add(layers.Dense(5))
    model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
                  loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
                  metrics=['accuracy'])
    return model

def buildModel_3(IMAGE_SIZE):
    # model architecture
    model = models.Sequential()
    model.add(layers.Conv2D(22 , (3, 3), activation='relu', kernel_regularizer=regularizers.l2(0.001), input_shape=(IMAGE_SIZE, IMAGE_SIZE, 3)))
    model.add(layers.Conv2D(32, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Dropout(0.3))
    model.add(layers.Conv2D(32, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.Dropout(0.3))
    model.add(layers.Conv2D(32, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Flatten())
    model.add(layers.Dense(32, kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.Dropout(0.4))
    model.add(layers.Dense(5,activation='softmax'))

    model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=0.0001),
                  loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
                  metrics=['accuracy'])
    return model
def buildModel_4(IMAGE_SIZE):

    model = models.Sequential()
    model.add(layers.Conv2D(32, (3, 3), activation='relu', kernel_regularizer=regularizers.l2(0.001),
                            input_shape=(IMAGE_SIZE, IMAGE_SIZE, 3)))
    model.add(layers.Dropout(0.2))
    model.add(layers.Conv2D(32, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Dropout(0.2))
    model.add(layers.Conv2D(32, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.Dropout(0.2))
    model.add(layers.Conv2D(32, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.Dropout(0.2))
    model.add(layers.Conv2D(32, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Dropout(0.2))
    model.add(layers.Conv2D(32, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.Dropout(0.2))
    model.add(layers.Conv2D(32, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.Dropout(0.2))
    model.add(layers.Conv2D(32, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Dropout(0.2))
    model.add(layers.Conv2D(32, (3, 3), kernel_regularizer=regularizers.l2(0.001), activation='relu'))
    model.add(layers.Flatten())
    model.add(layers.Dense(6, activation='softmax'))
    model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
                  loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
                  metrics=['accuracy'])
    return model

def buildModel_5(IMAGE_SIZE):
    model = models.Sequential()
    model.add(layers.Conv2D(32, (3, 3), activation='relu', input_shape=(IMAGE_SIZE, IMAGE_SIZE, 3)))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(32, (3, 3), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Dropout(0.2))
    model.add(layers.Conv2D(32, (3, 3), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(32, (3, 3), activation='relu'))
    model.add(layers.Flatten())
    model.add(layers.Dense(32, activation='softmax'))
    model.add(layers.Dense(6))
    model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
                  loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
                  metrics=['accuracy'])
    return model

def buildModel_6(IMAGE_SIZE):
    model = models.Sequential()
    model.add(layers.Conv2D(IMAGE_SIZE, (3, 3), activation='relu', input_shape=(IMAGE_SIZE, IMAGE_SIZE, 3)))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(32, (3, 3), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(32, (3, 3), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(32, (3, 3), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(32, (3, 3), activation='relu'))
    model.add(layers.Flatten())
    model.add(layers.Dense(32, activation='softmax'))
    model.add(layers.Dense(6, activation='softmax'))
    model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=0.0001),
                  loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
                  metrics=['accuracy'])
    return model
def buildModel_7(IMAGE_SIZE):
    model = models.Sequential()
    model.add(layers.Conv2D(IMAGE_SIZE, (3, 3), activation='relu', input_shape=(IMAGE_SIZE, IMAGE_SIZE, 3)))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(32, (3, 3), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(32, (3, 3), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(32, (3, 3), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(32, (3, 3), activation='relu'))
    model.add(layers.Flatten())
    model.add(layers.Dense(32, activation='softmax'))
    model.add(layers.Dense(6, activation='softmax'))
    model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=0.0001),
                  loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
                  metrics=['accuracy'])
    return model


def loadLatestWeight(model,checkpoint_path,):
    if os.path.isfile(checkpoint_path+".index"):
        checkpoint_dir = os.path.dirname(checkpoint_path[:-6])

        latest = tf.train.latest_checkpoint(checkpoint_dir)
        # loads the latest model weight
        model.load_weights(latest)
        print(latest)
    return model


def trainModel(model,trainData,testData,epoch,train_images,train_labels,test_images,test_labels):

    # callback to save the weight after every epoch
    cp_callback = tf.keras.callbacks.ModelCheckpoint(filepath=checkpoint_path,
                                                     save_weights_only=True,
                                                     verbose=1)

    # callback to visualize statistics of the model with TensorBoard
    log_dir = "logs\\fit\\" + datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    tensorboard_callback = tf.keras.callbacks.TensorBoard(log_dir=log_dir, histogram_freq=1)


    # trains the model
    history = model.fit(train_images, train_labels, epochs=epoch,
                        validation_data=(test_images, test_labels),
                        callbacks=[cp_callback,tensorboard_callback], batch_size=42)

    return model


def checkAcc(model,test_images,test_labels):

    # checks the accuracy of the model
    test_loss, test_acc = model.evaluate(test_images, test_labels)
    return test_acc

def saveModel(model,locationWithName):
    model.save_weights(locationWithName)



def process_test_data(TEST_DIR, IMG_SIZE):
    testing_data = []
    for img in tqdm(os.listdir(TEST_DIR)):
        path = os.path.join(TEST_DIR, img)
        img_name = img.split('.')[0]
        img = cv2.resize(cv2.imread(path, cv2.IMREAD_COLOR), (IMG_SIZE, IMG_SIZE))
        testing_data.append([np.array(img), img_name])
    return testing_data

def testModel(model,IMAGE_SIZE):
    data = process_test_data(".\\test_1",IMAGE_SIZE)

    test_images = np.array([i[0] for i in data]).reshape(-1, IMAGE_SIZE, IMAGE_SIZE, 3)
    test_images.astype('float32')
    test_images = test_images / 255.0
    test_labels = np.array([i[1] for i in data])



    prediction = model.predict_proba(test_images)
    print(prediction)
    j=0
    for i in range(len(test_labels)):
        plt.grid(False)
        plt.imshow(test_images[i], cmap=plt.cm.binary)
        plt.xlabel("Actual: "+ test_labels[i])
        plt.title("prediction: " + class_names[np.argmax(prediction[i])]+" ")
        plt.show()
        if(test_labels[i].lower() !=  class_names[np.argmax(prediction[i])].lower()):
            print(test_labels[i].lower() +' == '+class_names[np.argmax(prediction[i])].lower())
            j=j+1
    print(j)


    return model


def freezeModel(model):
    # Convert Keras model to ConcreteFunction
    full_model = tf.function(lambda x: model(x))
    full_model = full_model.get_concrete_function(
        tf.TensorSpec(model.inputs[0].shape, model.inputs[0].dtype))

    # Get frozen ConcreteFunction
    frozen_func = convert_variables_to_constants_v2(full_model)
    frozen_func.graph.as_graph_def()

    layers = [op.name for op in frozen_func.graph.get_operations()]
    print("-" * 50)
    print("Frozen model layers: ")
    for layer in layers:
        print(layer)

    print("-" * 50)
    print("Frozen model inputs: ")
    print(frozen_func.inputs)
    print("Frozen model outputs: ")
    print(frozen_func.outputs)

    # Save frozen graph from frozen ConcreteFunction to hard drive
    tf.io.write_graph(graph_or_graph_def=frozen_func.graph,
                      logdir="./frozen_models",
                      name="frozen_graph.pb",
                      as_text=False)

# Create a converter
def tfLiteCoverter(model):
    converter = tf.lite.TFLiteConverter.from_keras_model(model)# Convert the model
    tflite_model = converter.convert()# Create the tflite model file
    tflite_model_name = "m6.100.90.tflite"
    open(tflite_model_name, "wb").write(tflite_model)



IMAGE_SIZE = 100
# create_training_data(".\plant_train\def_data",IMAGE_SIZE,"training_data_new.")

# loads data
data = np.load("training_data_new."+str(IMAGE_SIZE)+".npy", allow_pickle=True)
# spits the data into training and test data
trainData = data[:-300]
testData = data[-300:]
# spits the data into image array and label array
train_images = np.array([i[0] for i in trainData]).reshape(-1, IMAGE_SIZE, IMAGE_SIZE, 3)
train_labels = np.array([i[1] for i in trainData])

# spits the data into image array and label array
test_images = np.array([i[0] for i in testData]).reshape(-1, IMAGE_SIZE, IMAGE_SIZE, 3)
test_labels = np.array([i[1] for i in testData])

train_images = train_images / 255.0
test_images = test_images / 255.0
print(np.std(train_images))
print(np.mean(train_images))

checkpoint_path = "training_1/cp.ckpt.index"

class_names = ['unknown', 'dracaena_lemon_lime', 'peace_lily', 'golden_pothos', 'snake_plant', 'croton']


#  corresponding Label value for each plant
# croton = 0
# dracaena_lemon_lime = 1
# peace_lily = 2
# pothos = 3
# snake_plant = 4

model = buildModel_6(IMAGE_SIZE)
# model = loadLatestWeight(model,checkpoint_path)
# model.load_weights(".\models\\m6_100_0.9\\")
acc = checkAcc(model,test_images,test_labels)
top = acc
# model = testModel(model,IMAGE_SIZE)
# while (True):
#     model = trainModel(model,trainData,testData ,20,train_images,train_labels,test_images,test_labels)
#     acc = checkAcc(model,test_images,test_labels)
#
#     if top < acc:
#         saveModel(model, './models/m7_100_'+str(acc)+'/')
#         top = acc






