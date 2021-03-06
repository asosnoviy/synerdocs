﻿
Перем _ИмяФормы;

Перем ДокументПодписан;

// Модули
Перем Телеметрия;
Перем СобытияТелеметрии;

Процедура ПодключитьМодули()
	
	Модули = ТребуютсяМодули("Модуль_Телеметрия");
	Телеметрия = Модули.Модуль_Телеметрия;
	
	СобытияТелеметрии = Телеметрия.ОписаниеСобытий();
	
КонецПроцедуры

Процедура ИнициализироватьФорму()
	
	ПодключитьМодули();
	
	ДокументПодписан = Ложь;
	
КонецПроцедуры

//========================================================================
// ЭКСПОРТНЫЙ ИНТЕРФЕЙС
//========================================================================

Функция ИмяФормы() Экспорт
	
	Если _ИмяФормы = Неопределено Тогда
		_ИмяФормы = ПолучитьИмяФормы(ЭтаФорма);
	КонецЕсли;
	
	Возврат _ИмяФормы;
	
КонецФункции


Процедура ПриОткрытии()
	
	УстановитьЗаголовокОкна(ЭтаФорма, "Подписать входящий документ");
	УстановитьВидимость();
	
	Если ЭД_Структура <> НЕОПРЕДЕЛЕНО Тогда
		ПредставлениеЭД = ЭД_Структура.ПредставлениеЭД;
	КонецЕсли;

КонецПроцедуры

// Процедура устанавливает доступность полей в зависимости от установленных флажков на форме
//
// Параметры:
//  Нет
//
Процедура УстановитьВидимость()	
	
	ЭлементыФормы.ФлагУчитыватьАкт.Доступность = ЭД_Структура.ТипЭД = "Акт об установленном расхождении";		
	ДокументБудетПодписан = ПолучитьПредставлениеСертификата();
	
КонецПроцедуры

Процедура ОсновныеДействияФормыОсновныеДействияФормыПодписать(Кнопка)

	//Создаем титул покупателя (торг-12 или акта), подписываем и отправляем
	//Получаем отправителя сообщения
	Попытка
		FullDocumentInfo = ExchangeService.GetFullDocumentInfo(Токен, Syn_ЯщикОрганизации, ЭД_Структура.Syn_IDДокумента,);
		ЯщикОтправителя = FullDocumentInfo.From;
		Syn_Документ = FullDocumentInfo.Document;
	Исключение
		ОписаниеОшибкиСтрокой = ОписаниеОшибки();
		ТекстОшибкиSynerdocs = РазобратьИсключениеSynerdocs(ОписаниеОшибкиСтрокой);
		
		ОтправитьУведомлениеПользователю("Ошибка получения информации об ЭД: " + ТекстОшибкиSynerdocs);
			
		Возврат;
		
	КонецПопытки;
	
	Попытка
		//формируем подписанта
								
		Тип_SignerInfo = ExchangeService.ФабрикаXDTO.Тип("http://schemas.datacontract.org/2004/07/Midway.ObjectModel", "SignerInfo");
		SignerInfo = ExchangeService.ФабрикаXDTO.Создать(Тип_SignerInfo);
		
		// Данные о пользователе 
		ДанныеПодписанта =  ExchangeService.GetUserInfo(Токен, Syn_ЯщикОрганизации);
			
		Если НЕ ЭтоБГУ Тогда
			SignerInfo.IsJuridical = (Организация.ЮрФизЛицо = Перечисления.ЮрФизЛицо.ЮрЛицо);
			Если SignerInfo.IsJuridical Тогда
				SignerInfo.OrganizationType = "LegalEntity";	
			Иначе
				SignerInfo.OrganizationType = "IndividualEntrepreneur";
			КонецЕсли;
			
		Иначе
			SignerInfo.IsJuridical = Истина;
			SignerInfo.OrganizationType = "LegalEntity";
		КонецЕсли;
		
		SignerInfo.Inn = Организация.ИНН;
		
		Если НЕ ЭтоБГУ Тогда
			Если Организация.ЮрФизЛицо = Перечисления.ЮрФизЛицо.ФизЛицо Тогда
				Если ЗначениеЗаполнено(Организация.СвидетельствоСерияНомер) И
					ЗначениеЗаполнено(Организация.СвидетельствоДатаВыдачи) Тогда
					SignerInfo.StateRegistrationCert = Организация.СвидетельствоСерияНомер + " от " + Формат(Организация.СвидетельствоДатаВыдачи, "ДЛФ=Д")
				Иначе
					SignerInfo.StateRegistrationCert = Организация.ОГРН;
				КонецЕсли;
			КонецЕсли;
		Иначе
			Если ЗначениеЗаполнено(Организация.СвидетельствоСерияНомер) И
				ЗначениеЗаполнено(Организация.СвидетельствоДатаВыдачи) Тогда
				SignerInfo.StateRegistrationCert = Организация.СвидетельствоСерияНомер + " от " + Формат(Организация.СвидетельствоДатаВыдачи, "ДЛФ=Д")
			КонецЕсли;			
		КонецЕсли;
				
		ФамилияПодписанта = ДанныеПодписанта.LastName;
		ИмяПодписанта = ДанныеПодписанта.FirstName;
		ОтчествоПодписанта = ?(ДанныеПодписанта.MiddleName = "", "", ДанныеПодписанта.MiddleName);
		ДолжностьПодписанта = ДанныеПодписанта.Position;
		
		SignerInfo.Position = ?(ПустаяСтрока(ДанныеПодписанта.Position), " ", ДанныеПодписанта.Position);
		SignerInfo.LastName = ФамилияПодписанта;
		SignerInfo.FirstName = ИмяПодписанта;
		SignerInfo.MiddleName = ОтчествоПодписанта;
			
			
		Если ЭД_Структура.ТипЭД = "Акт об установленном расхождении" Тогда
			 ТипЭД = "АктОбУстановленномРасхождении";
		Иначе			
			Сообщить("Не корректный вид документа " + ЭД_Структура.ТипЭД);
			Возврат;
		КонецЕсли;
		
		//Создаем массив документов
		Тип_ArrayOfDocument = ExchangeService.ФабрикаXDTO.Тип("http://schemas.datacontract.org/2004/07/Midway.ObjectModel", "ArrayOfDocument");
		ArrayOfDocument = ExchangeService.ФабрикаXDTO.Создать(Тип_ArrayOfDocument);
		
		//Создаем массив ЭЦП
		Тип_ArrayOfSign = ExchangeService.ФабрикаXDTO.Тип("http://schemas.datacontract.org/2004/07/Midway.ObjectModel", "ArrayOfSign");
		ArrayOfSign = ExchangeService.ФабрикаXDTO.Создать(Тип_ArrayOfSign);
		
		//Двоичные данные титула покупателя
		ТитулПокупателя_Структура = Неопределено;
		
		//Если ТитулПокупателя_Контент <> НЕОПРЕДЕЛЕНО Тогда
		Если ТитулПокупателя_Структура <> НЕОПРЕДЕЛЕНО И
			ТитулПокупателя_Структура.Документ_ДвоичныеДанные <> НЕОПРЕДЕЛЕНО Тогда
			//Создаем Document в СО
			Syn_ТитулПокупателя = СоздатьОбъект_Document(, ТитулПокупателя_Структура.Документ_ДвоичныеДанные, ТипЭД, ТитулПокупателя_Структура.Документ_ИмяФайла, Syn_Документ,);
										
			//Формируем ЭЦП к документу
			ЭЦП_ДвоичныеДанные = СформироватьЭЦПДокумента(, ТитулПокупателя_Структура.Документ_ДвоичныеДанные, ТитулПокупателя_Структура.Документ_ИмяФайла);
			
			//создаем Подпись в СО
			Syn_ЭЦП = СоздатьОбъект_Sign(Syn_ТитулПокупателя.Id, ЭЦП_ДвоичныеДанные);
			
			м_Documents = Новый Массив;
			м_Signs = Новый Массив;
			
			м_Documents.Добавить(Syn_ТитулПокупателя); 
			м_Signs.Добавить(Syn_ЭЦП);

			ArrayOfDocument.Document.Добавить(Syn_ТитулПокупателя);
			
			ArrayOfSign.Sign.Добавить(Syn_ЭЦП);			
		КонецЕсли;
		
		// Подписываем входящий акт
		Если ТипЭД = "АктОбУстановленномРасхождении" Тогда
			Контент = ?(Syn_Документ.Content = Неопределено, ExchangeService.GetDocumentContent(Токен, Syn_ЯщикОрганизации,Syn_Документ.Id), Syn_Документ.Content);
			ЭЦП_ДвоичныеДанные = СформироватьЭЦПДокумента(, Контент, Syn_Документ.FileName);
			Syn_ЭЦП = СоздатьОбъект_Sign(Syn_Документ.Id, ЭЦП_ДвоичныеДанные);
			
			ArrayOfSign.Sign.Добавить(Syn_ЭЦП);			
		КонецЕсли;
					
		// Добавим Акт о расхождении
		Если ФлагУчитыватьАкт Тогда
			
			Если НЕ ЗначениеЗаполнено(ДокументКорректировкаНеформализованый) Тогда
				Предупреждение("Не выбран файл акта об установленных расхождениях. Подписание не возможно.");
				Возврат;
			КонецЕсли;
						
			КарточкаТОРГ2 = НЕОПРЕДЕЛЕНО;
			
			КонтентТОРГ2 = Новый Структура;
			КонтентТОРГ2.Вставить("Документ_ДвоичныеДанные", Новый ДвоичныеДанные(ДокументКорректировкаНеформализованый));
			ДокументФайл = Новый Файл(ДокументКорректировкаНеформализованый);
			КонтентТОРГ2.Вставить("Документ_ИмяФайла", ДокументФайл.Имя);
						
			Syn_ДокументТОРГ2 = СоздатьОбъект_Document(,КонтентТОРГ2.Документ_ДвоичныеДанные,"АктОбУстановленномРасхождении",КонтентТОРГ2.Документ_ИмяФайла,,);
			Syn_ДокументТОРГ2.Card = НЕОПРЕДЕЛЕНО;
			Syn_ДокументТОРГ2.UntypedKind = "Акт об установленном расхождении";
			Syn_ДокументТОРГ2.NeedSign = Истина;
			Syn_ДокументТОРГ2.Date = ТекущаяДата();
			Syn_ДокументТОРГ2.ParentDocumentId = Syn_Документ.Id;
			
			ArrayOfDocument.Document.Добавить(Syn_ДокументТОРГ2);
						
			// связываем документы
			Тип_ArrayOfstring = ExchangeService.ФабрикаXDTO.Тип("http://schemas.microsoft.com/2003/10/Serialization/Arrays", "ArrayOfstring");
			ArrayOfString = ExchangeService.ФабрикаXDTO.Создать(Тип_ArrayOfstring);
			
			ArrayOfString.string.Добавить(Syn_Документ.Id);
			Syn_ДокументТОРГ2.RelatedDocumentIds = ArrayOfString;
			
			ЭЦП_ДвоичныеДанные_ТОРГ2 = СформироватьЭЦПДокумента(, КонтентТОРГ2.Документ_ДвоичныеДанные, Syn_ДокументТОРГ2.FileName);
			Syn_ЭЦП_ТОРГ2 = СоздатьОбъект_Sign(Syn_ДокументТОРГ2.Id, ЭЦП_ДвоичныеДанные_ТОРГ2);
			
			ArrayOfSign.Sign.Добавить(Syn_ЭЦП_ТОРГ2);
			
		КонецЕсли;
		
		//Создаем сообщение в СО и отправляем его
		Тип_Message = ExchangeService.ФабрикаXDTO.Тип("http://schemas.datacontract.org/2004/07/Midway.ObjectModel", "Message");
		Message = ExchangeService.ФабрикаXDTO.Создать(Тип_Message);
		Message.Documents = ArrayOfDocument;
		
		
		Message.From = Syn_ЯщикОрганизации;
		Message.Signs = ArrayOfSign;
		Message.To = ЯщикОтправителя;	
		Message.Id = Строка(Новый УникальныйИдентификатор());
	Исключение
		ОписаниеОшибкиСтрокой = ОписаниеОшибки();
		ТекстОшибкиSynerdocs = РазобратьИсключениеSynerdocs(ОписаниеОшибкиСтрокой);
		
		ОтправитьУведомлениеПользователю("Ошибка в подписании документа (формировании титула покупателя): " + ТекстОшибкиSynerdocs);
				
		Возврат;
		
	КонецПопытки;
	
	Если ОтправитьСообщениеВСервисОбмена(Message) <> НЕОПРЕДЕЛЕНО Тогда
		ДокументПодписан = Истина;
		ЭтаФорма.Закрыть(Истина);
	КонецЕсли;
	
КонецПроцедуры
 
Процедура ФлагУчитыватьАктПриИзменении(Элемент)
	
	ЭлементыФормы.ДокументКорректировкаНеформализованый.Доступность = ФлагУчитыватьАкт;
	
КонецПроцедуры

Функция ЗаполнитьСтруктуруАдреса(АдресXDTO) Экспорт
	
	Если НЕ АдресXDTO.АдрРФ = Неопределено Тогда 
			
			АдрРФ = АдресXDTO.АдрРФ;
			Адрес = Новый Структура;
			Адрес.Вставить("Индекс", АдрРФ.Индекс);
			Адрес.Вставить("КодРегион", АдрРФ.КодРегион);
			Адрес.Вставить("Район", АдрРФ.Район);
			Адрес.Вставить("Город", АдрРФ.Город);
			Адрес.Вставить("НаселПункт", АдрРФ.НаселПункт);
			Адрес.Вставить("Улица", АдрРФ.Улица);
			Адрес.Вставить("Дом", АдрРФ.Дом);
			Адрес.Вставить("Корпус", АдрРФ.Корпус);
			Адрес.Вставить("Кварт", АдрРФ.Кварт);
			
		ИначеЕсли НЕ АдресXDTO.АдрИно = Неопределено Тогда
			
			АдрИно = АдресXDTO.АдрИно;
			Адрес = Новый Структура;
			Адрес.Вставить("КодСтраны", АдрИно.КодСтр);
			АДрес.Вставить("АдрТекст", АдрИно.АдрТекст);
		
		КонецЕсли;

	    Возврат Адрес;	
	
	КонецФункции

Процедура ДокументКорректировкаНеформализованыйНачалоВыбора(Элемент, СтандартнаяОбработка)
	
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогВыбораФайла.Заголовок = "Выберите Акт о расхождении";
	ДиалогВыбораФайла.ПредварительныйПросмотр = Истина;

	Если ДиалогВыбораФайла.Выбрать() Тогда
		ДокументКорректировкаНеформализованый = ДиалогВыбораФайла.ПолноеИмяФайла;
	КонецЕсли;

КонецПроцедуры

Процедура ПриЗакрытии()
	
	Если НЕ ДокументПодписан Тогда
		Телеметрия.ОтправитьАналитику(
			СобытияТелеметрии.Подписание.Отмена,
			ЭтаФорма
		);
	КонецЕсли;
	
КонецПроцедуры


ИнициализироватьФорму();
