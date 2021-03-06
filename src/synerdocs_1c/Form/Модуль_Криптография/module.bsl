﻿
Процедура Инициализировать() Экспорт
КонецПроцедуры

//========================================================================
// Объекты
//========================================================================

Функция Новый_Субъект()
	
	Субъект = Новый Структура(
		"ИНН,
		|ФИО, Должность,
		|НаименованиеОрганизации,
		|
		|ТипСубъекта"
	);
	
	Субъект.ФИО = Новый_ФИО();
	
	Возврат Субъект;
	
КонецФункции

Функция Новый_Сертификат() Экспорт
	
	Сертификат = Новый Структура(
		"Субъект, Издатель, СерийныйНомер"
	);
	
	Сертификат.Субъект = Новый_Субъект();
	Сертификат.Издатель = Новый_Субъект();
	
	Возврат Сертификат;
	
КонецФункции

Функция Новый_ФИО()
	
	ФИО = Новый Структура(
		"Фамилия, Имя, Отчество"
	);
	
	Возврат ФИО;
	
КонецФункции

//========================================================================
// Перечисления
//========================================================================

Функция ТипыСубъекта() Экспорт
	
	ТипыСубъекта = Новый Структура(
		"ЮрЛицо, ИП, ФизЛицо"
	);
	
	ТипыСубъекта.ЮрЛицо		= 0;
	ТипыСубъекта.ИП			= 1;
	ТипыСубъекта.ФизЛицо	= 2;
	
	ТипыСубъекта = Новый ФиксированнаяСтруктура(ТипыСубъекта);
	Возврат ТипыСубъекта;
	
КонецФункции

Функция ПоляСубъекта()
	
	ПоляСубъекта = Новый Структура(
		"ОбщееИмя, 
		|Фамилия, Имя,
		|Должность,
		|НаименованиеОрганизации,
		|ИНН, ОГРН, ОГРНИП, СНИЛС"
	);
	
	ПоляСубъекта.ОбщееИмя					= "CN";
	
	ПоляСубъекта.Фамилия					= "SN";
	ПоляСубъекта.Имя						= "GN";
	
	ПоляСубъекта.Должность					= "T";
	
	ПоляСубъекта.НаименованиеОрганизации	= "O";
	
	ПоляСубъекта.ИНН						= "OID1_2_643_3_131_1_1";
	ПоляСубъекта.ОГРН						= "OID1_2_643_100_1";
	ПоляСубъекта.ОГРНИП						= "OID1_2_643_100_5";
	ПоляСубъекта.СНИЛС						= "OID1_2_643_100_3";
	
	ПоляСубъекта = Новый ФиксированнаяСтруктура(ПоляСубъекта);
	Возврат ПоляСубъекта;
	
КонецФункции

//========================================================================
// Работа с субъектом/издателем
//========================================================================

Функция ЗначениеПоляСубъекта(СубъектСертификата, Поле)
	
	//: СубъектСертификата = Новый ФиксированнаяСтруктура;
	
	Результат = Неопределено;
	Если СубъектСертификата.Свойство(Поле) Тогда
		Результат = СубъектСертификата[Поле];
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция ТипСубъекта(СубъектСертификата)
	
	//: СубъектСертификата = Новый ФиксированнаяСтруктура;
	
	ПоляСубъекта = ПоляСубъекта();
	ТипыСубъекта = ТипыСубъекта();
	
	ЕстьИНН		= СубъектСертификата.Свойство(ПоляСубъекта.ИНН);
	ЕстьОГРН	= СубъектСертификата.Свойство(ПоляСубъекта.ОГРН);
	ЕстьОГРНИП	= СубъектСертификата.Свойство(ПоляСубъекта.ОГРНИП);
	ЕстьСНИЛС	= СубъектСертификата.Свойство(ПоляСубъекта.СНИЛС);
	
	Если ЕстьСНИЛС И НЕ ЕстьОГРН И НЕ ЕстьОГРНИП Тогда
		ТипСубъекта = ТипыСубъекта.ФизЛицо;
	ИначеЕсли НЕ ЕстьОГРН И ЕстьОГРНИП И ЕстьИНН Тогда
		ТипСубъекта = ТипыСубъекта.ИП;
	ИначеЕсли ЕстьОГРН И НЕ ЕстьОГРНИП И ЕстьИНН Тогда
		ТипСубъекта = ТипыСубъекта.ЮрЛицо;
	Иначе
		ТипСубъекта = Неопределено;
	КонецЕсли;
	
	Возврат ТипСубъекта;

КонецФункции

Функция Субъект(СубъектСертификата) Экспорт
	
	Субъект = Новый_Субъект();
	
	ПоляСубъекта = ПоляСубъекта();
	ТипыСубъекта = ТипыСубъекта();
	
	ТипСубъекта = ТипСубъекта(СубъектСертификата);
	
	// ФИО
	Фамилия = ЗначениеПоляСубъекта(СубъектСертификата, ПоляСубъекта.Фамилия);
	ИмяОтчество = ЗначениеПоляСубъекта(СубъектСертификата, ПоляСубъекта.Имя);
	Если ЗначениеЗаполнено(Фамилия) И ЗначениеЗаполнено(ИмяОтчество) Тогда
		
		ФамилияИмяОтчество = Фамилия + " " + ИмяОтчество;
		ФИО = ЧастиИмени(ФамилияИмяОтчество);
		
	Иначе
		
		ФИО = Новый_ФИО();
		
		ФамилияИмяОтчество = ЗначениеПоляСубъекта(СубъектСертификата, ПоляСубъекта.ОбщееИмя);
		ЧастиИмени = СтрРазделить2(ФамилияИмяОтчество, " ", Ложь, Истина);
		Если ЧастиИмени.Количество() = 3 Тогда
			ФИО.Фамилия		= ЧастиИмени[0];
			ФИО.Имя			= ЧастиИмени[1];
			ФИО.Отчество	= ЧастиИмени[2];
		КонецЕсли;
		
	КонецЕсли;
	
	// ИНН
	ИНН = ЗначениеПоляСубъекта(СубъектСертификата, ПоляСубъекта.ИНН);
	// Для юр.лиц в сертфикатах стоят лишних два ноля впереди
	Если ТипСубъекта = ТипыСубъекта.ЮрЛицо Тогда
		ИНН = Сред(ИНН, 3);
	КонецЕсли;
	
	// Должность
	Должность = ЗначениеПоляСубъекта(СубъектСертификата, ПоляСубъекта.Должность);
	
	// Наименование организации
	НаименованиеОрганизации = ЗначениеПоляСубъекта(СубъектСертификата, ПоляСубъекта.НаименованиеОрганизации);
	
	// Установка значений
	Субъект.ТипСубъекта = ТипСубъекта;
	
	Субъект.ИНН = ИНН;
	
	ЗаполнитьЗначенияСвойств(Субъект.ФИО, ФИО, "Фамилия, Имя, Отчество");
	Субъект.Должность = Должность;
	
	Субъект.НаименованиеОрганизации = НаименованиеОрганизации;
	
	Субъект = Новый ФиксированнаяСтруктура(Субъект);
	Возврат Субъект;
	
КонецФункции

//========================================================================
// Работа с сертификатом
//========================================================================

Функция Сертификат(СертификатКриптографии) Экспорт
	
	//: СертификатКриптографии = Новый СертификатКриптографии;
	
	Сертификат = Новый_Сертификат();
	
	Сертификат.Субъект	= Субъект(СертификатКриптографии.Субъект);
	Сертификат.Издатель	= Субъект(СертификатКриптографии.Издатель);
	
	СерийныйНомер = Строка(СертификатКриптографии.СерийныйНомер);
	СерийныйНомер = СтрЗаменить(СерийныйНомер, " ", "");
	
	Сертификат.СерийныйНомер = СерийныйНомер;
	
	Сертификат = ФиксированныеДанные(Сертификат);
	Возврат Сертификат;
	
КонецФункции

Функция СертификатПодписи(Подпись) Экспорт
	
	//: МенеджерКриптографии = Новый МенеджерКриптографии;
	
	СертификатыВПодписи = МенеджерКриптографии.ПолучитьСертификатыИзПодписи(Подпись);
	СертификатПодписи = СертификатыВПодписи[0];
	
	Сертификат = Сертификат(СертификатПодписи);
	
	Возврат Сертификат;
	
КонецФункции
