﻿
Перем _Параметры;
Перем _ИмяФормы;

Перем ДокументПодписан;

// Параметры
Перем ТипДокумента;
Перем ИдТитулаПродавца;
Перем ЕстьПриемщик;
Перем ЕстьВидОперации;
Перем ЕстьСведенияОПолученииВещи;
Перем НаименованиеОрганизацииПодписантаОбязательно;
Перем ВидСодержимого;

// Модули
Перем ОбъектнаяМодель, ФормированиеДокументов, Телеметрия;
Перем СобытияТелеметрии;

Процедура ПодключитьМодули()
	
	Модули = ТребуютсяМодули("Модуль_ОбъектнаяМодель, Модуль_ФормированиеДокументов, Модуль_Телеметрия");
	ОбъектнаяМодель			= Модули.Модуль_ОбъектнаяМодель;
	ФормированиеДокументов	= Модули.Модуль_ФормированиеДокументов;
	Телеметрия				= Модули.Модуль_Телеметрия;
	
	СобытияТелеметрии = Телеметрия.ОписаниеСобытий();
	
КонецПроцедуры

Процедура ИзвлечьПараметры()
	
	Если _Параметры = Неопределено Тогда
		ВызватьИсключение "Параметры формы не установлены";
	КонецЕсли;
	
	ТипДокумента		= _Параметры.ТипДокумента;
	ИдТитулаПродавца	= _Параметры.ИД;
	
КонецПроцедуры


Процедура ИнициализироватьФорму()
	
	ДокументПодписан = Ложь;
	
	// Значения переключателей
	ВидыПодписанта = ВидыПодписанта();
	ЭлементыФормы.ПодписантВидЮрЛицо.ВыбираемоеЗначение		= ВидыПодписанта.ЮрЛицо;
	ЭлементыФормы.ПодписантВидИП.ВыбираемоеЗначение			= ВидыПодписанта.ИП;
	ЭлементыФормы.ПодписантВидФизЛицо.ВыбираемоеЗначение	= ВидыПодписанта.ФизЛицо;
	
	ВидыСтатуса = СтатусыПриемщика();
	ЭлементыФормы.ПриемщикСтатусНеУказан.ВыбираемоеЗначение								= ВидыСтатуса.НеУказан;
	ЭлементыФормы.ПриемщикСтатусСотрудникОрганизации.ВыбираемоеЗначение					= ВидыСтатуса.СотрудникОрганизации;
	ЭлементыФормы.ПриемщикСтатусПредставительДовереннойОрганизации.ВыбираемоеЗначение	= ВидыСтатуса.ПредставительДовереннойОрганизации;
	ЭлементыФормы.ПриемщикСтатусФизЛицо.ВыбираемоеЗначение								= ВидыСтатуса.ФизЛицо;
	
	УстановитьВидПодписанта(ВидыПодписанта.ЮрЛицо);
	УстановитьСтатусПриемщика(ВидыСтатуса.НеУказан);
	
	// Списки выбора
	ДопустимыеОбластиПолномочий = ОбъектнаяМодель.ДопустимыеОбластиПолномочий(ТипДокумента);
	
	ЭлементыФормы.ПодписантОбластьПолномочий.СписокВыбора	= СписокЗначенийИзПеречисления(ОбъектнаяМодель.ОбластиПолномочий(), ДопустимыеОбластиПолномочий);
	ЭлементыФормы.ПодписантСтатус.СписокВыбора				= СписокЗначенийИзПеречисления(ОбъектнаяМодель.СтатусыПодписанта());
	
	ПодписантОбластьПолномочий	= ПервоеЗначениеИзСписка(ЭлементыФормы.ПодписантОбластьПолномочий.СписокВыбора);
	ПодписантСтатус				= ПервоеЗначениеИзСписка(ЭлементыФормы.ПодписантСтатус.СписокВыбора);
	
КонецПроцедуры

Процедура ЗаполнитьПоляПоУмолчанию()
	
	Подписант = ФормированиеДокументов.ПодписантПоУмолчанию();
	
	//ПодписантОбластьПолномочий				= Подписант.ОбластьПолномочий;
	//ПодписантСтатус							= Подписант.Статус;
	ПодписантОснованиеПолномочий			= Подписант.ОснованиеПолномочий;
	ПодписантОснованиеПолномочийОрганизации	= Подписант.ОснованиеПолномочийОрганизации;
	
	ВидыПодписанта = ИнвертироватьСоответствие(Соответствие_ВидПодписантаТипОрганизации());
	ВидПодписанта = ВидыПодписанта[Подписант.ТипОрганизации];
	УстановитьВидПодписанта(ВидПодписанта);
	
	ПодписантИНН			= Подписант.ИНН;
	ПодписантФамилия		= Подписант.ФИО.Фамилия;
	ПодписантИмя			= Подписант.ФИО.Имя;
	ПодписантОтчество		= Подписант.ФИО.Отчество;
	ПодписантИныеСведения	= Подписант.ДопИнфо;
	
	ВидыПодписанта = ВидыПодписанта();
	Если ПодписантВид = ВидыПодписанта.ЮрЛицо Тогда
		ПодписантНаименованиеОрганизации	= Подписант.НаименованиеОрганизации;
		ПодписантДолжность					= Подписант.Должность;
	ИначеЕсли ПодписантВид = ВидыПодписанта.ИП Тогда
		ПодписантСведенияОРегистрацииИП = Подписант.СвидетельствоОРегистрацииИП;
	КонецЕсли;
	
	Составитель = ФормированиеДокументов.СоставительДокументаПоУмолчанию();
	СоставительНаименование			= Составитель.НаименованиеОрганизации;
	СоставительОснованиеПолномочий	= Составитель.ОснованиеПолномочий;
		
КонецПроцедуры

Процедура ЗаполнитьПризнаки()
	
	ТипыДокументов = ОбъектнаяМодель.ТипыДокументов();
	ВидыПодписанта = ВидыПодписанта();
	
	ЕстьПриемщик	= ОбъектнаяМодель.ЕстьПриемщик(ТипДокумента);
	ВидСодержимого	= ОбъектнаяМодель.ВидСодержимого(ТипДокумента);
	
	ЕстьВидОперации									= НЕ (ТипДокумента = ТипыДокументов.ТитулПокупателяУКД);
	НаименованиеОрганизацииПодписантаОбязательно	= (ПодписантВид = ВидыПодписанта.ЮрЛицо);
	ЕстьСведенияОПолученииВещи						= (ТипДокумента = ТипыДокументов.ТитулЗаказчикаДПРР);
	
КонецПроцедуры

Процедура УстановитьОтображение()
	
	ОбластьПолномочийДоступность = (ЭлементыФормы.ПодписантОбластьПолномочий.СписокВыбора.Количество() > 1);
	ЭлементыФормы.ПодписантОбластьПолномочий.Доступность = ОбластьПолномочийДоступность;
	
	ЭлементыФормы.НадписьВидОперации.Доступность	= ЕстьВидОперации;
	ЭлементыФормы.ВидОперации.Доступность			= ЕстьВидОперации;
	
	ЭлементыФормы.Приемщик.Доступность = ЕстьПриемщик;
	
	ЭлементыФормы.СведенияОПолученииВещи.Видимость = ЕстьСведенияОПолученииВещи;
	
	ВидыСодержимого = ОбъектнаяМодель.ВидыСодержимогоДокумента();
	ТекстДатаПриемки = Новый Соответствие;
	ТекстДатаПриемки[ВидыСодержимого.Товары]		= "Дата принятия товара";
	ТекстДатаПриемки[ВидыСодержимого.Работы]		= "Дата приемки результатов";
	ТекстДатаПриемки[ВидыСодержимого.Корректировка]	= "Дата согласования";
	
	ЭлементыФормы.НадписьДатаПриемки.Заголовок = ТекстДатаПриемки[ВидСодержимого] + ":";
	
	ЭлементыФормы.ПодписантНаименованиеОрганизации.ОтметкаНезаполненного			= Ложь;
	ЭлементыФормы.ПодписантНаименованиеОрганизации.АвтоОтметкаНезаполненного		= НаименованиеОрганизацииПодписантаОбязательно;
	ЭлементыФормы.ПодписантОснованиеПолномочийОрганизации.ОтметкаНезаполненного		= Ложь;
	ЭлементыФормы.ПодписантОснованиеПолномочийОрганизации.АвтоОтметкаНезаполненного	= ПроверятьОснованиеПолномочийОрганизации();
	
КонецПроцедуры


Функция ВидыПодписанта()
	
	Виды = Новый Структура(
		"ЮрЛицо, ИП, ФизЛицо"
	);
	
	Виды.ЮрЛицо		= 0;
	Виды.ИП			= 1;
	Виды.ФизЛицо	= 2;
	
	Виды = Новый_Перечисление(Виды);
	
	Возврат Виды;
	
КонецФункции

Функция СтатусыПриемщика()
	
	Виды = Новый Структура(
		"НеУказан,
		|СотрудникОрганизации, ПредставительДовереннойОрганизации, ФизЛицо"
	);
	
	Виды.НеУказан = 0;
	
	Виды.СотрудникОрганизации				= 1;
	Виды.ПредставительДовереннойОрганизации	= 2;
	Виды.ФизЛицо							= 3;
	
	Виды = Новый_Перечисление(Виды);
	
	Возврат Виды;
	
КонецФункции

Функция Соответствие_ВидПодписантаТипОрганизации()
	
	ВидыПодписанта = ВидыПодписанта();
	ТипыОрганизации = ОбъектнаяМодель.ТипыОрганизации();
	
	Соответствие = Новый Соответствие;
	Соответствие[ВидыПодписанта.ЮрЛицо]		= ТипыОрганизации.ЮрЛицо;
	Соответствие[ВидыПодписанта.ИП]			= ТипыОрганизации.ИП;
	Соответствие[ВидыПодписанта.ФизЛицо]	= ТипыОрганизации.ФизЛицо;
	
	Возврат Соответствие;
	
КонецФункции

Функция Соответствие_СтатусПриемщикаВидыОтветственногоЛица()
	
	СтатусыПриемщика = СтатусыПриемщика();
	ВидыОтветственногоЛица = ОбъектнаяМодель.ВидыОтветственногоЛица();
	
	Соответствие = Новый Соответствие;
	Соответствие[СтатусыПриемщика.СотрудникОрганизации]					= ВидыОтветственногоЛица.СотрудникОрганизации;
	Соответствие[СтатусыПриемщика.ПредставительДовереннойОрганизации]	= ВидыОтветственногоЛица.ПредставительДовереннойОрганизации;
	Соответствие[СтатусыПриемщика.ФизЛицо]								= ВидыОтветственногоЛица.ФизЛицо;
	
	Возврат Соответствие;
	
КонецФункции

Процедура УстановитьВидПодписанта(НовыйВид)
	
	ВидыПодписанта = ВидыПодписанта();
	
	Если ЗначениеПринадлежитПеречислению(НовыйВид, ВидыПодписанта) Тогда
		ПодписантВид = НовыйВид;
	Иначе
		ПодписантВид = ВидыПодписанта.ЮрЛицо;
	КонецЕсли;
	
	
	Страницы = Новый Соответствие;
	Страницы[ВидыПодписанта.ЮрЛицо]		= ЭлементыФормы.ВидыПодписанта.Страницы.ЮрЛицо;
	Страницы[ВидыПодписанта.ИП]			= ЭлементыФормы.ВидыПодписанта.Страницы.ИП;
	Страницы[ВидыПодписанта.ФизЛицо]	= ЭлементыФормы.ВидыПодписанта.Страницы.ФизЛицо;
	
	Страница = Страницы[ПодписантВид];
	
	ЭлементыФормы.ВидыПодписанта.ТекущаяСтраница = Страница;
	
КонецПроцедуры

Процедура УстановитьСтатусПриемщика(НовыйСтатус)
	
	СтатусыПриемщика = СтатусыПриемщика();
	
	Если ЗначениеПринадлежитПеречислению(НовыйСтатус, СтатусыПриемщика) Тогда
		ПриемщикСтатус = НовыйСтатус;
	Иначе
		ПриемщикСтатус = СтатусыПриемщика.СотрудникОрганизации;
	КонецЕсли;
	
	
	Если ПриемщикСтатус = СтатусыПриемщика.НеУказан Тогда
		
		ЭлементыФормы.ВидыПриемщика.Доступность = Ложь;
		
	Иначе
		
		ЭлементыФормы.ВидыПриемщика.Доступность = Истина;
	
		Страницы = Новый Соответствие;
		Страницы[СтатусыПриемщика.СотрудникОрганизации]					= ЭлементыФормы.ВидыПриемщика.Страницы.СотрудникОрганизации;
		Страницы[СтатусыПриемщика.ПредставительДовереннойОрганизации]	= ЭлементыФормы.ВидыПриемщика.Страницы.ПредставительДовереннойОрганизации;
		Страницы[СтатусыПриемщика.ФизЛицо]								= ЭлементыФормы.ВидыПриемщика.Страницы.ФизЛицо;
		
		Страница = Страницы[ПриемщикСтатус];
		
		ЭлементыФормы.ВидыПриемщика.ТекущаяСтраница = Страница;
		
	КонецЕсли;
	
КонецПроцедуры


Функция ИмяФормы() Экспорт
	
	Если _ИмяФормы = Неопределено Тогда
		_ИмяФормы = ПолучитьИмяФормы(ЭтаФорма);
	КонецЕсли;
	
	Возврат _ИмяФормы;
	
КонецФункции


Функция Параметры() Экспорт
	
	Параметры = Новый Структура(
		"ТипДокумента, ИД"
	);
	
	Возврат Параметры;
	
КонецФункции

Процедура УстановитьПараметры(Параметры) Экспорт
	
	_Параметры = ФиксированныеДанные(Параметры);
	
КонецПроцедуры


Процедура ПередОткрытием(Отказ, СтандартнаяОбработка)
	
	ИзвлечьПараметры();
	
	ИнициализироватьФорму();
	ЗаполнитьПоляПоУмолчанию();
	
	ЗаполнитьПризнаки();
	
КонецПроцедуры

Процедура ПриОткрытии()
	
	УстановитьОтображение();
	
КонецПроцедуры

Процедура ПриЗакрытии()
	
	Если НЕ ДокументПодписан Тогда
		Телеметрия.ОтправитьАналитику(
			СобытияТелеметрии.Подписание.Отмена,
			ЭтаФорма
		);
	КонецЕсли;
	
КонецПроцедуры


Процедура ДопИнфоПриВыводеСтроки(Элемент, ОформлениеСтроки, ДанныеСтроки)
	
	НомерСтроки = ДопИнфо.Индекс(ДанныеСтроки) + 1;
	ОформлениеСтроки.Ячейки.НомерСтроки.УстановитьТекст(НомерСтроки);
	
КонецПроцедуры

Процедура ДопИнфоПередНачаломДобавления(Элемент, Отказ, Копирование)
	
	МаксимальныйРазмер = 20;
	
	КоличествоПолей = ДопИнфо.Количество();
	Если КоличествоПолей = МаксимальныйРазмер Тогда
		
		ТекстСообщения = СтрШаблон2("Может быть добавлено не более %1 полей", МаксимальныйРазмер);
		Предупреждение(ТекстСообщения);
		
		Отказ = Истина;
		
	КонецЕсли;
	
КонецПроцедуры


Процедура ОсновныеДействияФормыПодписать(Кнопка)
	
	Подписать();
	
КонецПроцедуры


Процедура ПодписантВидПриИзменении(Элемент)
	
	УстановитьВидПодписанта(ПодписантВид);
	ВидыПодписанта = ВидыПодписанта();
	НаименованиеОрганизацииПодписантаОбязательно = (ПодписантВид = ВидыПодписанта.ЮрЛицо);
	
КонецПроцедуры

Процедура ПодписантСтатусПриИзменении(Элемент)
	
	УстановитьОтображение();
	
КонецПроцедуры


Процедура ПриемщикСтатусПриИзменении(Элемент)
	
	УстановитьСтатусПриемщика(ПриемщикСтатус);
	
КонецПроцедуры



//========================================================================
// Команды
//========================================================================

Процедура Подписать()
	
	Если НЕ ПроверитьЗаполнениеФормы(ЭтаФорма) Тогда
		Возврат;
	КонецЕсли;
	
	Данные = Результат();
	ТитулПокупателя = ФормированиеДокументов.ТитулПокупателя(ТипДокумента, Данные);
	
	РезультатСериализации = ФормированиеДокументов.МодельВДокумент(ТипДокумента, ТитулПокупателя, ИдТитулаПродавца);
	
	Если РезультатСериализации.ЕстьОшибки Тогда
		Возврат;
	КонецЕсли;
	
	ДокументПодписан = Истина;
	
	ОповеститьОВыборе(РезультатСериализации.Документ);
	
КонецПроцедуры


//========================================================================
// Формирование результата
//========================================================================

Функция Результат()
	
	Результат = ФормированиеДокументов.Новый_ДанныеТитулаПокупателя();
	
	Результат.ВидОперации = НеопределеноЕслиНеЗаполнено(ВидОперации);
	
	Результат.ОписаниеОперации			= ОписаниеОперации();
	Результат.СведенияОПолученииВещи	= СведенияОПолученииВещи();
	
	Результат.Подписант = Подписант();
	Результат.Приемщик = Приемщик();
	
	// Дополнительная информация
	ИнфПоле = Результат.ИнфПоле;
	Для Каждого СтрокаДопИнфо Из ДопИнфо Цикл
		НовоеПоле = ИнфПоле.Добавить();
		НовоеПоле.Идентификатор	= СтрокаДопИнфо.Поле;
		НовоеПоле.Значение		= СтрокаДопИнфо.Значение;
	КонецЦикла;
	
	Результат.Составитель = Составитель();
	
	Возврат Результат;
	
КонецФункции

Функция ОписаниеОперации()
	
	ОписаниеОперации = ОбъектнаяМодель.Новый_ОписаниеОперации();
	
	ОписаниеОперации.Описание	= СодержаниеОперации;
	ОписаниеОперации.Дата		= НеопределеноЕслиНеЗаполнено(ДатаПриемки);
	
	Возврат ОписаниеОперации;
	
КонецФункции

Функция СведенияОПолученииВещи()
	
	Если ЕстьСведенияОПолученииВещи Тогда
		
		ОписаниеОперации = ОбъектнаяМодель.Новый_ОписаниеОперации();
		
		ОписаниеОперации.Описание	= НеопределеноЕслиНеЗаполнено(СведенияОПолучении);
		ОписаниеОперации.Дата		= НеопределеноЕслиНеЗаполнено(ДатаПолученияВещи);
		
	Иначе
		
		ОписаниеОперации = Неопределено;
		
	КонецЕсли;
	
	Возврат ОписаниеОперации;
	
КонецФункции

Функция ФИО(Фамилия, Имя, Отчество)
	
	ФИО = ОбъектнаяМодель.Новый_ФИО();
	
	ФИО.Фамилия		= Фамилия;
	ФИО.Имя			= Имя;
	ФИО.Отчество	= НеопределеноЕслиНеЗаполнено(Отчество);
	
	Возврат ФИО;
	
КонецФункции

Функция Подписант()
	
	Подписант = ОбъектнаяМодель.Новый_Подписант();
	
	Подписант.Статус							= ПодписантСтатус;
	Подписант.ОбластьПолномочий					= ПодписантОбластьПолномочий;
	Подписант.ОснованиеПолномочий				= ПодписантОснованиеПолномочий;
	Подписант.ОснованиеПолномочийОрганизации	= НеопределеноЕслиНеЗаполнено(ПодписантОснованиеПолномочийОрганизации);
	
	ТипыОрганизации = Соответствие_ВидПодписантаТипОрганизации();
	Подписант.ТипОрганизации = ТипыОрганизации[ПодписантВид];
	
	Подписант.ИНН = НеопределеноЕслиНеЗаполнено(ПодписантИНН);
	Подписант.ДопИнфо = НеопределеноЕслиНеЗаполнено(ПодписантИныеСведения);
	
	Подписант.ФИО = ФИО(ПодписантФамилия, ПодписантИмя, ПодписантОтчество);
	
	Подписант.НаименованиеОрганизации	= НеопределеноЕслиНеЗаполнено(ПодписантНаименованиеОрганизации);
	Подписант.Должность					= ПодписантДолжность;
	
	Подписант.СвидетельствоОРегистрацииИП = НеопределеноЕслиНеЗаполнено(ПодписантСведенияОРегистрацииИП);
	
	Возврат Подписант;
	
КонецФункции

Функция Приемщик()
	
	Если ПриемщикДоступен() Тогда
		
		Приемщик = ОбъектнаяМодель.Новый_ОтветственноеЛицо();
		
		ВидыПриемщика = Соответствие_СтатусПриемщикаВидыОтветственногоЛица();
		Приемщик.Вид = ВидыПриемщика[ПриемщикСтатус];
		
		Приемщик.ФИО = ФИО(ПриемщикФамилия, ПриемщикИмя, ПриемщикОтчество);
		
		Приемщик.ОснованиеПолномочий	= НеопределеноЕслиНеЗаполнено(ПриемщикОснованиеПолномочий);
		Приемщик.ОснованиеДоверия		= НеопределеноЕслиНеЗаполнено(ПриемщикОснованиеДоверия);
		Приемщик.Должность				= ПриемщикДолжность;
		
		Приемщик.НаименованиеОрганизации = ПриемщикНаименованиеОрганизации;
		
	Иначе
		
		Приемщик = Неопределено;
		
	КонецЕсли;
	
	Возврат Приемщик;
	
КонецФункции

Функция Составитель()
	
	Составитель = ОбъектнаяМодель.Новый_СоставительДокумента();
	
	Составитель.НаименованиеОрганизации	= СоставительНаименование;
	Составитель.ОснованиеПолномочий		= НеопределеноЕслиНеЗаполнено(СоставительОснованиеПолномочий);
	
	Возврат Составитель;
	
КонецФункции

Функция ПриемщикДоступен()
	
	СтатусыПриемщика = СтатусыПриемщика();
	
	Результат = Истина
		И ЕстьПриемщик 
		И ПриемщикСтатус <> СтатусыПриемщика.НеУказан;
	
	Возврат Результат;
	
КонецФункции


//========================================================================
// Проверка заполнения
//========================================================================

Функция ПроверятьОснованиеПолномочийОрганизации()
	
	СтатусыПодписанта = ОбъектнаяМодель.СтатусыПодписанта();
	
	Результат = (ПодписантСтатус = СтатусыПодписанта.РаботникИнойОрганизации);
	
	Возврат Результат;
	
КонецФункции

Функция ПроверяемыеРеквизиты() Экспорт
	
	Поля = Новый СписокЗначений;
	
	Поля.Добавить("СодержаниеОперации", "Содержание операции");
	
	Поля.Добавить("ПодписантОснованиеПолномочий",             "Подписант: Основание полномочий");
	Поля.Добавить("ПодписантОснованиеПолномочийОрганизации",  "Подписант: Основ. полномоч. орг-ции");	
	Поля.Добавить("ПодписантНаименованиеОрганизации",         "Подписант: Наименование");	
	Поля.Добавить("ПодписантИНН",                             "Подписант: ИНН");
	Поля.Добавить("ПодписантДолжность",                       "Подписант: Должность");
	Поля.Добавить("ПодписантФамилия",                         "Подписант: Фамилия");
	Поля.Добавить("ПодписантИмя",                             "Подписант: Имя");
	
	Поля.Добавить("СоставительНаименование", "Наим. экон. субъекта");
	
	Поля.Добавить("ПриемщикДолжность",					"Лицо, принявшее товар: Должность");
	Поля.Добавить("ПриемщикФамилия",					"Лицо, принявшее товар: Фамилия");
	Поля.Добавить("ПриемщикИмя",						"Лицо, принявшее товар: Имя");
	Поля.Добавить("ПриемщикНаименованиеОрганизации",	"Лицо, принявшее товар: Наименование");
	
	ПредставлениеТЧ = НСтр("ru = 'Дополнительная информация'");
	Поля.Добавить("ДопИнфо.Поле",     ПредставлениеТЧ + НСтр("ru = '#Поле'"));
	Поля.Добавить("ДопИнфо.Значение", ПредставлениеТЧ + НСтр("ru = '#Значение'"));
	
	Возврат Поля;
	
КонецФункции

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеПоля) Экспорт
	
	НепроверяемыеПоля = Новый Массив;
	
	СтатусыПриемщика = СтатусыПриемщика();
	
	Если ПриемщикДоступен() Тогда
		
		Если ПриемщикСтатус = СтатусыПриемщика.СотрудникОрганизации Тогда
			НепроверяемыеПоля.Добавить("ПриемщикНаименованиеОрганизации");
		ИначеЕсли ПриемщикСтатус = СтатусыПриемщика.ФизЛицо Тогда
			НепроверяемыеПоля.Добавить("ПриемщикНаименованиеОрганизации");
			НепроверяемыеПоля.Добавить("ПриемщикДолжность");
		КонецЕсли;
		
	Иначе
		
		НепроверяемыеПоля.Добавить("ПриемщикДолжность");
		НепроверяемыеПоля.Добавить("ПриемщикФамилия");
		НепроверяемыеПоля.Добавить("ПриемщикИмя");
		НепроверяемыеПоля.Добавить("ПриемщикНаименованиеОрганизации");
		
	КонецЕсли;
	
	Если НЕ НаименованиеОрганизацииПодписантаОбязательно Тогда
		НепроверяемыеПоля.Добавить("ПодписантНаименованиеОрганизации");
	КонецЕсли;
	
	Если НЕ ПроверятьОснованиеПолномочийОрганизации() Тогда
		НепроверяемыеПоля.Добавить("ПодписантОснованиеПолномочийОрганизации");
	КонецЕсли;
	
	ВидыПодписанта = ВидыПодписанта();
	
	ПроверятьИННПодписанта = (ПодписантВид <> ВидыПодписанта.ФизЛицо);
	Если НЕ ПроверятьИННПодписанта Тогда
		НепроверяемыеПоля.Добавить("ПодписантИНН");
	КонецЕсли;
	
	ПроверятьДолжностьПодписанта = (ПодписантВид = ВидыПодписанта.ЮрЛицо);
	Если НЕ ПроверятьДолжностьПодписанта Тогда
		НепроверяемыеПоля.Добавить("ПодписантДолжность");
	КонецЕсли;
		
	УдалитьНепроверяемыеРеквизиты(ПроверяемыеПоля, НепроверяемыеПоля);
	
КонецПроцедуры


ПодключитьМодули();
