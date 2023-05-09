
# Импортируем библиотеки
import speech_recognition as sr
import pyautogui as pag
import pyperclip
import threading
import pyttsx3
import ctypes
from pynput.keyboard import Key, Controller
import pynput
import tkinter as tk


is_run = True
play_command = True
is_dubbing = False
text_is_commad = False


# Изменяем текст надписи
def text_in_label(txt):
    """
    НАЗВАНИЕ
      Изменение текста надписи - text_in_label()

    ОПИСАНИЕ
      Функция используется для изменения текста в графическом интерфейсе программы.

    ПАРАМЕТРЫ
      txt (str) - строка, которая должна отображаться в надписи.

    ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
      Нет возвращаемых значений.
    """
    label.config(text='\n'+txt+'\n')


# выполняется при закрытии окна
def on_closing():
    """
    НАЗВАНИЕ
      Закрытие окна - on_closing()

    ОПИСАНИЕ
      Функция выполняется при закрытии графического интерфейса и останавливает работу программы.

    ПАРАМЕТРЫ
      Нет параметров.

    ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
      Нет возвращаемых значений.
    """
    global is_run, play_command

    is_run = False
    play_command = False
    try:
        print("Окно закрыто")
        background_thread.join()
        root.destroy()
        root.quit()
    except Exception as e:
        root.quit()
        print('on_closing  '+e)

# Объявляем функции для кнопок
def button_play_callback():
    """
    НАЗВАНИЕ
      Обработка нажатия кнопки "Play" - button_play_callback()

    ОПИСАНИЕ
      Функция используется при нажатии пользователем на кнопку "Play". Функция запускает запись голоса.

    ПАРАМЕТРЫ
      Нет параметров.

    ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
      Нет возвращаемых значений.
    """
    global play_command
    play_command = True
    button_play.config(bg='green')
    button_pause.config(bg='red')


def button_pause_callback():
    """
    НАЗВАНИЕ
      Обработка нажатия кнопки "Pause" - button_pause_callback()

    ОПИСАНИЕ
      Функция используется при нажатии пользователем на кнопку "Pause". Функция останавливает запись голоса.

    ПАРАМЕТРЫ
      Нет параметров.

    ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
      Нет возвращаемых значений.
    """
    global play_command
    play_command = False
    button_play.config(bg='red')
    button_pause.config(bg='green')


def button_voiceover_on_callback():
    """
    НАЗВАНИЕ
      Обработка нажатия кнопки "Voiceover On" - button_voiceover_on_callback()

    ОПИСАНИЕ
      Функция используется при нажатии пользователем на кнопку "Voiceover On". Функция включает режим озвучки текста.

    ПАРАМЕТРЫ
      Нет параметров.

    ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
      Нет возвращаемых значений.
    """
    global is_dubbing
    is_dubbing = True
    button_voiceover_on.config(bg='green')
    button_voiceover_off.config(bg='red')


def button_voiceover_off_callback():
    """
    НАЗВАНИЕ
      Обработка нажатия кнопки "Voiceover Off" - button_voiceover_off_callback()

    ОПИСАНИЕ
      Функция используется при нажатии пользователем на кнопку "Voiceover Off". Функция выключает режим озвучки текста.

    ПАРАМЕТРЫ
      Нет параметров.

    ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
      Нет возвращаемых значений.
    """
    global is_dubbing
    is_dubbing = False
    button_voiceover_on.config(bg='red')
    button_voiceover_off.config(bg='green')


def switch_keyboard_layout():
    """
    НАЗВАНИЕ
      Переключение раскладки клавиатуры - switch_keyboard_layout()

    ОПИСАНИЕ
      Функция переключает раскладку клавиатуры на английскую.

    ПАРАМЕТРЫ
      Нет параметров.

    ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
      Нет возвращаемых значений.
    """
    # Получаем текущую раскладку клавиатуры
    keyboard_layout = ctypes.windll.user32.GetKeyboardLayout(0)
    # Проверяем текущую раскладку. Если раскладка не английская, то переключаем на английскую
    if keyboard_layout == 68748313:
        keyboard = Controller()
        # Нажимаем Alt-Shift
        keyboard.press(Key.alt_l)
        keyboard.press(Key.shift_l)
        # Отжимаем Alt-Shift
        keyboard.release(Key.alt_l)
        keyboard.release(Key.shift_l)


# Функция, которая будет выполняться в фоновом режиме
def background_task():
    def paste_text(txt):
        """
        НАЗВАНИЕ
            Вставка текста из буфера обмена - paste_text()

        ОПИСАНИЕ
            Функция реализует вставку текста из буфера обмена
            в текущую позицию курсора мыши.
        ПАРАМЕТРЫ
            Аргументы функции:
            * txt - строка.
        ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
            Нет возвращаемых значений.
        """
        # загрузка текста в буфер
        pyperclip.copy(txt + ' ')
        # получаем положение мыши и кликаем
        pag.click(pag.position())
        # получаем положение мыши
        mouse = pynput.mouse.Controller()
        # кликаем
        mouse.click(pynput.mouse.Button.left)
        # вставка из буфера
        keyboard = pynput.keyboard.Controller()
        keyboard.press(pynput.keyboard.Key.ctrl)
        keyboard.press('v')
        keyboard.release(pynput.keyboard.Key.ctrl)
        keyboard.release('v')
        # очистка буфера
        pyperclip.copy('')

    def clean_text():
        """
        НАЗВАНИЕ
            Очистка текста - clean_text()

        ОПИСАНИЕ
            Функция реализует очистку текста из текущего положения курсора мыши.

        ПАРАМЕТРЫ
            Нет параметров.

        ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
            Нет возвращаемых значений.
        """
        # получаем положение мыши и кликаем
        # pag.click(pag.position())
        # # выделяем всё
        # pag.hotkey('ctrl', 'a')
        # # удаляем
        # pag.hotkey('del')
        print('Очистка  -  ')
        # получаем положение мыши
        mouse = pynput.mouse.Controller()
        # кликаем
        mouse.click(pynput.mouse.Button.left)
        # вставка из буфера
        keyboard = pynput.keyboard.Controller()
        keyboard.press(pynput.keyboard.Key.ctrl)
        keyboard.press('a')
        keyboard.release(pynput.keyboard.Key.ctrl)
        keyboard.release('a')
        keyboard.press(pynput.keyboard.Key.delete)
        keyboard.release(pynput.keyboard.Key.delete)



    def commands(txt):
        """
        НАЗВАНИЕ
          Обработка пользовательских команд - commands()

        ОПИСАНИЕ
          Функция обрабатывает введенные пользователем команды и выполняет соответствующие действия.

        ПАРАМЕТРЫ
          text (str) - строка, содержащая пользовательскую команду.

        ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
          Нет возвращаемых значений.
        """
        global is_run, play_command, is_dubbing
        commands_dict = {
            'stop': ['остановись', 'выключись', 'хватит'],
            'dubbing_play': ['включи озвучку', 'озвучивай'],
            'dubbing_stop': ['выключи озвучку', 'отключи озвучку', 'перестань говорить', 'хватит говорить'],
            'clean': ['очистить текст', 'очисти поле', 'очистить поле','удалить текст', 'удали текст', 'очисти текст'],
            'pause': ['сделай паузу', 'останови запись', 'пауза', 'паузу', 'подожди'],
            'play': ['включись', 'начни запись', 'записывай', 'продолжи', 'продолжим']
        }

        for command, values in commands_dict.items():
            if any(value in txt.lower() for value in values):
                global text_is_commad
                if command == 'stop':
                    is_run = False
                    play_command = False
                    print('Остановка  -  ' + txt)
                    text_is_commad = True
                    on_closing()
                elif command in ('dubbing_play', 'dubbing_stop'):
                    is_dubbing = not is_dubbing
                    print('Озвучка  -  ' + str(is_dubbing) + '  ' + txt)
                    if is_dubbing:
                        button_voiceover_on_callback()
                    else:
                        button_voiceover_off_callback()
                    text_is_commad = True
                elif command == 'clean':
                    clean_text()
                    text_is_commad = True
                elif command == 'pause':
                    play_command = False
                    button_pause_callback()
                    text_is_commad = True
                elif command == 'play':
                    button_play_callback()
                    play_command = True
                    text_is_commad = True

    def dubbing(txt):
        """
        НАЗВАНИЕ
          Дублирование текста - dubbing()

        ОПИСАНИЕ
          Функция используется для дублирования текста с помощью синтеза речи.

        ПАРАМЕТРЫ
          text (str) - строка, которую нужно произнести.

        ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
          Нет возвращаемых значений.
        """
        if is_dubbing:
            # voices = engine.getProperty('voices')  # получить список доступных голосов
            # engine.setProperty('voice', voices[0].id)
            engine.setProperty('rate', 350)  # устанавливает скорость голоса
            engine.setProperty('volume', 1)  # устанавливает громкость
            engine.say(txt)  # что будем говорить
            engine.runAndWait()  # Запуск движка голоса

    global is_run
    global play_command

    # Создаем объект распознавателя речи
    r = sr.Recognizer()
    # Инициализируем движок синтеза речи
    engine = pyttsx3.init()
    # Цикл для получения распознанной речи
    while is_run:
        text = ''
        # Попытка получения аудио данных с микрофона
        try:
            # Добавляем возможность получения аудио данных с микрофона
            with sr.Microphone() as source:
                # Отключаем автонастройку уровня громкости
                r.adjust_for_ambient_noise(source, duration=0.5)
                print('Диктуйте фразу для распознавания')
                text_in_label('Диктуйте фразу для распознавания')
                # Слушаем микрофон и сохраняем аудио-данные
                audio_data = r.listen(source)
                # Распознаем аудио-данные
                text = (r.recognize_google(audio_data, language='ru-RU')).lower()
        # Если произошла ошибка, выводим ее
        except Exception as e:
            print('Не распознано', e)
            text_in_label('Не распознано')

        # Выводим распознанную фразу на экран
        print('text  -  ' + text)
        text_in_label(text)
        # вставляем текст в буфер обмена
        if text == '':
            pass

        else:
            global text_is_commad
            text_is_commad = False
            # Проверяем наличие команд в тексте
            commands(text)

            if not text_is_commad:
                if play_command:
                    # pyperclip.copy(text + ' ')
                    # Вставляем текст там, где указатель мыши
                    paste_text(text)
                    # Вызываем функцию для озвучки распознанной фразы
                    dubbing(text)
                text_is_commad = False
        if not is_run:
            print('if not is_run')
            background_thread.join()
            return



if __name__ == '__main__':
    try:
        # Переключаемся на английскую раскладку
        switch_keyboard_layout()
        # Запуск потока, который будет выполнять фоновую задачу
        background_thread = threading.Thread(target=background_task)
        background_thread.start()

        # Создаем окно
        root = tk.Tk()
        root.title("SpeechReco")

        label = tk.Label(root, text="\n\n\n")  # создаем надпись
        label.pack()  # добавляем надпись на окно

        # Создаем кнопки
        width = 33
        button_play = tk.Button(root, text="Включить прослушивание", command=button_play_callback,  width=width)
        button_pause = tk.Button(root, text="Приостановить прослушивание", command=button_pause_callback,  width=width)
        button_voiceover_on = tk.Button(root, text="Включить озвучку", command=button_voiceover_on_callback,  width=width)
        button_voiceover_off = tk.Button(root,
                                         text="Приостановить озвучку",
                                         command=button_voiceover_off_callback,
                                         width=width)

        # задаём начальные значения цвета кнопок
        button_play.config(bg='green')
        button_pause.config(bg='red')
        button_voiceover_on.config(bg='red')
        button_voiceover_off.config(bg='green')

        # Помещаем кнопки в окно
        button_play.pack()
        button_pause.pack()
        button_voiceover_on.pack()
        button_voiceover_off.pack()

        # назначение функции при закрытии окна
        root.protocol("WM_DELETE_WINDOW", on_closing)

        # Устанавливаем флаг topmost (по верх всех окон)
        root.attributes("-topmost", True)

        # изменяем размер окна
        root.geometry("250x170")

        # Запускаем окно
        root.mainloop()
    except Exception as e:
        print(e)
