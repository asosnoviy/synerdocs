﻿
//========================================================================
// Форма заполнения реквизитов подписанта.
// Используется для заполнения объекта Модуль_ОбъектнаяМодель.Новый_Подписант().
//========================================================================

Перем _Параметры;

// Модули
Перем ОбъектнаяМодель, РаботаСФормами;

//========================================================================
// ИНИЦИАЛИЗАЦИЯ
//========================================================================

Процедура ПодключитьМодули()
	
	ОбъектнаяМодель	= Модуль("Модуль_ОбъектнаяМодель");
	РаботаСФормами	= Модуль("Модуль_РаботаСФормами");
	
КонецПроцедуры

Процедура Инициализировать()
	
	ПодключитьМодули();
	
КонецПроцедуры

Процедура ИнициализироватьФорму()
	
	Параметры = ПараметрыФормы();
	
	ТипДокумента = Параметры.ТипДокумента;
	
	// Значения переключателей
	ВидыПодписанта = ОбъектнаяМодель.ТипыОрганизации();
	ЭлементыФормы.ВидПодписантаЮрЛицо.ВыбираемоеЗначение	= ВидыПодписанта.ЮрЛицо;
	ЭлементыФормы.ВидПодписантаИП.ВыбираемоеЗначение		= ВидыПодписанта.ИП;
	ЭлементыФормы.ВидПодписантаФизЛицо.ВыбираемоеЗначение	= ВидыПодписанта.ФизЛицо;
	
	// Списки выбора
	ДопустимыеОбластиПолномочий = ОбъектнаяМодель.ДопустимыеОбластиПолномочий(ТипДокумента);
	
	ЭлементыФормы.ОбластьПолномочий.СписокВыбора	= СписокЗначенийИзПеречисления(ОбъектнаяМодель.ОбластиПолномочий(), ДопустимыеОбластиПолномочий);
	ЭлементыФормы.Статус.СписокВыбора				= СписокЗначенийИзПеречисления(ОбъектнаяМодель.СтатусыПодписанта());
	
	ОбластьПолномочий	= ПервоеЗначениеИзСписка(ЭлементыФормы.ОбластьПолномочий.СписокВыбора);
	Статус				= ПервоеЗначениеИзСписка(ЭлементыФормы.Статус.СписокВыбора);
	
	УстановитьВидПодписанта(ВидыПодписанта.ЮрЛицо);
	
	УстановитьПодписанта(Параметры.Модель);
	
КонецПроцедуры

Функция ПараметрыФормы()
	
	Если _Параметры = Неопределено Тогда
		ВызватьИсключение "Параметры формы не установлены";
	КонецЕсли;
	
	Возврат _Параметры;
	
КонецФункции

//========================================================================
// ЭКСПОРТНЫЙ ИНТЕРФЕЙС
//========================================================================

Функция Параметры() Экспорт
	
	Параметры = Новый Структура(
		"Модель,
		|ТипДокумента"
	);
	
	Параметры.Модель		= Неопределено; //: Модуль_ОбъектнаяМодель.Новый_Подписант();
	Параметры.ТипДокумента	= Неопределено; //: Модуль_ОбъектнаяМодель.ТипыДокументов();
	
	Возврат Параметры;
	
КонецФункции

Функция УстановитьПараметры(Параметры) Экспорт
	
	_Параметры = ФиксированныеДанные(Параметры);
	
КонецФункции

Функция ПроверяемыеРеквизиты() Экспорт
	
	Поля = Новый СписокЗначений;
	
	Поля.Добавить("ОснованиеПолномочий",             НСтр("ru = 'Основание полномочий'"));
	Поля.Добавить("ОснованиеПолномочийОрганизации",  НСтр("ru = 'Основ. полномоч. орг-ции'"));
	Поля.Добавить("ИНН",                             НСтр("ru = 'ИНН'"));
	Поля.Добавить("Должность",                       НСтр("ru = 'Должность'"));
	Поля.Добавить("Фамилия",                         НСтр("ru = 'Фамилия'"));
	Поля.Добавить("Имя",                             НСтр("ru = 'Имя'"));
	
	Возврат Поля;
	
КонецФункции

//========================================================================
// СОБЫТИЯ
//========================================================================

//===================================
//{ События формы

Процедура ПередОткрытием(Отказ, СтандартнаяОбработка)
	
	ИнициализироватьФорму();
	
КонецПроцедуры

Процедура ПриОткрытии()
	
	УстановитьОтображение();
	
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты) Экспорт
	
	НепроверяемыеРеквизиты = Новый Массив;
	
	ВидыПодписанта = ОбъектнаяМодель.ТипыОрганизации();
	
	ПроверятьИННПодписанта = (ВидПодписанта <> ВидыПодписанта.ФизЛицо);
	Если НЕ ПроверятьИННПодписанта Тогда
		НепроверяемыеРеквизиты.Добавить("ИНН");
	КонецЕсли;
	
	ПроверятьДолжностьПодписанта = (ВидПодписанта = ВидыПодписанта.ЮрЛицо);
	Если НЕ ПроверятьДолжностьПодписанта Тогда
		НепроверяемыеРеквизиты.Добавить("Должность");
	КонецЕсли;
	
	Если НЕ ОснованиеПолномочийОрганизацииОбязательно() Тогда
		НепроверяемыеРеквизиты.Добавить("ОснованиеПолномочийОрганизации");
	КонецЕсли;
	
	УдалитьНепроверяемыеРеквизиты(ПроверяемыеРеквизиты, НепроверяемыеРеквизиты);
	
КонецПроцедуры

//}

//===================================
//{ Кнопки формы

Процедура ОсновныеДействияФормыСохранить(Кнопка)
	
	Если НЕ ПроверитьЗаполнениеФормы(ЭтаФорма) Тогда
		Возврат;
	КонецЕсли;
	
	Сохранить();
	
КонецПроцедуры

//}

//===================================
//{ События элементов формы

Процедура СтатусПриИзменении(Элемент)
	
	УстановитьСтатус(Статус);
	
КонецПроцедуры

Процедура ВидПодписантаПриИзменении(Элемент)
	
	УстановитьВидПодписанта(ВидПодписанта);
	
КонецПроцедуры

//}

//===================================
//{ Команды

Процедура Сохранить()
	
	Результат = Подписант();
	ОповеститьОВыборе(Результат);
	
КонецПроцедуры

//}

//========================================================================
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ
//========================================================================

Процедура УстановитьОтображение()
	
	СтраницыПодписанта = Новый Соответствие;
	СтраницыПодписанта[ЭлементыФормы.ВидПодписантаЮрЛицо.ВыбираемоеЗначение]	= ЭлементыФормы.ВидыПодписанта.Страницы.ЮрЛицо;
	СтраницыПодписанта[ЭлементыФормы.ВидПодписантаИП.ВыбираемоеЗначение]		= ЭлементыФормы.ВидыПодписанта.Страницы.ИП;
	СтраницыПодписанта[ЭлементыФормы.ВидПодписантаФизЛицо.ВыбираемоеЗначение]	= ЭлементыФормы.ВидыПодписанта.Страницы.ФизЛицо;
	
	ЭлементыФормы.ВидыПодписанта.ТекущаяСтраница = СтраницыПодписанта[ВидПодписанта];
	
	РаботаСФормами.УстановитьАвтоОтметкуНезаполненного(ЭлементыФормы.ОснованиеПолномочийОрганизации, ОснованиеПолномочийОрганизацииОбязательно());
	
КонецПроцедуры

//===================================
//{ Геттеры и сеттеры

// Модель формы

Процедура УстановитьПодписанта(НовоеЗначение)
	
	Если НовоеЗначение = Неопределено Тогда
		Подписант = ОбъектнаяМодель.Новый_Подписант();
	Иначе
		Подписант = НовоеЗначение;
	КонецЕсли;
	
	ЗаполнитьЗначенияСвойств(
		ЭтаФорма,
		Подписант,
		"ОбластьПолномочий, Статус, ОснованиеПолномочий, ОснованиеПолномочийОрганизации,
		|ИНН,
		|НаименованиеОрганизации, Должность,
		|СвидетельствоОРегистрацииИП"
	);
	
	ИныеСведения = Подписант.ДопИнфо;
	
	ЗаполнитьЗначенияСвойств(ЭтаФорма, Подписант.ФИО, "Фамилия, Имя, Отчество");
	
	УстановитьВидПодписанта(Подписант.ТипОрганизации);
	
КонецПроцедуры

Функция Подписант()
	
	Подписант = ОбъектнаяМодель.Новый_Подписант();
	
	Подписант.ТипОрганизации = ВидПодписанта;
	
	ЗаполнитьЗначенияСвойств(
		Подписант,
		ЭтаФорма,
		"ОбластьПолномочий, Статус, ОснованиеПолномочий, ОснованиеПолномочийОрганизации,
		|ИНН"
	);
	ЗаполнитьЗначенияСвойств(Подписант.ФИО, ЭтаФорма, "Фамилия, Имя, Отчество");
	Подписант.ДопИнфо = ИныеСведения;
	
	ВидыПодписанта = ОбъектнаяМодель.ТипыОрганизации();
	
	Если ВидПодписанта = ВидыПодписанта.ЮрЛицо Тогда
		ЗаполнитьЗначенияСвойств(Подписант, ЭтаФорма, "НаименованиеОрганизации, Должность");
	ИначеЕсли ВидПодписанта = ВидыПодписанта.ИП Тогда
		ЗаполнитьЗначенияСвойств(Подписант, ЭтаФорма, "СвидетельствоОРегистрацииИП");
	КонецЕсли;
	
	Возврат Подписант;
	
КонецФункции

// Прочее

Процедура УстановитьСтатус(НовоеЗначение)
	
	Статус = НовоеЗначение;
	
	УстановитьОтображение();
	
КонецПроцедуры

Процедура УстановитьВидПодписанта(НовоеЗначение)
	
	ВидПодписанта = НовоеЗначение;
	
	УстановитьОтображение();
	
КонецПроцедуры

//}

Функция ОснованиеПолномочийОрганизацииОбязательно()
	
	Результат = (Статус = ОбъектнаяМодель.СтатусыПодписанта().РаботникИнойОрганизации);
	
	Возврат Результат;
	
КонецФункции


Инициализировать();
