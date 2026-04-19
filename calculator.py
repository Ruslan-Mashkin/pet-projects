#!/usr/bin/env python3
"""
Простой консольный калькулятор для обучения работе с Git и GitHub.
Поддерживает операции: сложение, вычитание, умножение, деление.
"""

def add(x, y):
    """Сложение двух чисел."""
    return x + y

def subtract(x, y):
    """Вычитание двух чисел."""
    return x - y

def multiply(x, y):
    """Умножение двух чисел."""
    return x * y

def divide(x, y):
    """Деление двух чисел. Возвращает ошибку при делении на ноль."""
    if y == 0:
        return "Ошибка: деление на ноль!"
    return x / y

def main():
    print("=== Добро пожаловать в простой калькулятор! ===")
    print("Выберите операцию:")
    print("1. Сложение (+)")
    print("2. Вычитание (-)")
    print("3. Умножение (*)")
    print("4. Деление (/)")

    while True:
        choice = input("\nВведите номер операции (1/2/3/4) или 'q' для выхода: ")

        if choice.lower() == 'q':
            print("Спасибо за использование калькулятора. До свидания!")
            break

        if choice not in ('1', '2', '3', '4'):
            print("Неверный ввод. Попробуйте снова.")
            continue

        try:
            num1 = float(input("Введите первое число: "))
            num2 = float(input("Введите второе число: "))
        except ValueError:
            print("Ошибка: введите корректное число.")
            continue

        if choice == '1':
            result = add(num1, num2)
            op_symbol = '+'
        elif choice == '2':
            result = subtract(num1, num2)
            op_symbol = '-'
        elif choice == '3':
            result = multiply(num1, num2)
            op_symbol = '*'
        elif choice == '4':
            result = divide(num1, num2)
            op_symbol = '/'

        print(f"Результат: {num1} {op_symbol} {num2} = {result}")

if __name__ == "__main__":
    main()
