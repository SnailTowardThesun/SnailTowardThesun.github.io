---
layout: article
title: tensorflow tutorial
categories: machine-learning
---

# Tensorflow使用基本介绍

## 关键流程以及重点函数介绍

### 单机训练

使用tensorflow.keras作为高阶API封装入口，实现模型训练和使用模型预测两大功能。

#### 模型训练基本流程

在使用高阶API tensorflow.keras的时，我们搭建网络主要依赖于[`tf.keras.Sequential`](https://www.tensorflow.org/api_docs/python/tf/keras/Sequential)。简单的使用流程可以参考下面的代码以及注释。

```
"""
do pnet train
"""
import tensorflow as tf
import numpy as np


def keras_demo():
    """basic way to use tensorflow.keras
    """

    """create network
    # 直接在初始化model的时候填入网络结构
    model = tf.keras.Sequential(
        tf.keras.Dense(32, input_shape=(784,)),
        tf.kears.Activation('relu'),
    )
    """

    # we can also create network with .add
    # 如果网络结构过于复杂，我们也可以通过调用add的方式，逐层添加网络
    model = tf.keras.Sequential()
    model.add(tf.keras.layers.Dense(32, activation='relu', input_dim=100))
    model.add(tf.keras.layers.Dense(1, activation='sigmoid'))
    model.compile(optimizer='rmsprop',
                  loss='binary_crossentropy',
                  metrics=['accuracy'])

    # do train
    data = np.random.random((1000, 100))
    labels = np.random.randint(2, size=(1000, 1))

    # Train the model, iterating on the data in batches of 32 samples
    model.fit(data, labels, epochs=10, batch_size=32)


if __name__ == '__main__':
    """test for tensorflow.keras
    """
    print('tf version: %s, keras version: %s' % (tf.__version__, tf.keras.__version__))
    keras_demo()
```

以一个实际算法来详细说明函数调用

```
import numpy as np
from tensorflow import keras

from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten
from keras.layers import Conv2D, MaxPooling2D
from keras.optimizers import SGD

# 生成训练数据

# 作为图片输入，一共会随机生成100个，3*100*100，即分辨率为100x100的RGB格式图像
x_train = np.random.random((100, 100, 100, 3)) 

# 为100个图像输入生成100个label
y_train = keras.utils.to_categorical(np.random.randint(10, size=(100, 1)), num_classes=10)

# 生成20个图像作为测试数据
x_test = np.random.random((20, 100, 100, 3))

# 同样为测试数据生成label
y_test = keras.utils.to_categorical(np.random.randint(10, size=(20, 1)), num_classes=10)

# 准备开始构建网络
model = Sequential()

# 添加一个2维，32x3x3的卷积层，输入为3*100*100
model.add(Conv2D(32, (3, 3), activation='relu', input_shape=(100, 100, 3)))

# 添加一个2维，32x3x3的卷积层，输入为上一层的输出
model.add(Conv2D(32, (3, 3), activation='relu'))

# 添加一个2维，2x2的池化层
model.add(MaxPooling2D(pool_size=(2, 2)))

# 为了防止过拟合，增加dropout层
model.add(Dropout(0.25))

# 增加一个2维，64x3x3的卷积层
model.add(Conv2D(64, (3, 3), activation='relu'))

# 增加一个2维，64x3x3的卷积层
model.add(Conv2D(64, (3, 3), activation='relu'))

# 增加一个2维，2x2的池化层
model.add(MaxPooling2D(pool_size=(2, 2)))

# 为防止过拟合，增加dropout层
model.add(Dropout(0.25))

# 增加Flatten层，用于数据进行full connect前的处理
model.add(Flatten())

# 增加全连接层
model.add(Dense(256, activation='relu'))

# 为防止过拟合，增加dropout层
model.add(Dropout(0.5))

# 增加全连接层
model.add(Dense(10, activation='softmax'))

# 使用随机梯度下降算法
sgd = SGD(lr=0.01, decay=1e-6, momentum=0.9, nesterov=True)

# 完成网络构建
model.compile(loss='categorical_crossentropy', optimizer=sgd)

# 开始训练
model.fit(x_train, y_train, batch_size=32, epochs=10)

# 获取loss
score = model.evaluate(x_test, y_test, batch_size=32)
```

### 分布式训练

<strong>TODO</strong>