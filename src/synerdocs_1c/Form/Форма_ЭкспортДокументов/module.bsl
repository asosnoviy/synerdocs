﻿
Перем _ИмяФормы;

Перем ВыгрузкаЗавершена;

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
	
	ВыгрузкаЗавершена = Ложь;
	
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


Процедура КнопкаВыполнитьНажатие(Кнопка)
	
	Файл_КаталогЭкспортаЭД = Новый Файл(КаталогЭкспортаЭД);	
	
	Если Файл_КаталогЭкспортаЭД.Существует() И Файл_КаталогЭкспортаЭД.ЭтоКаталог() Тогда
		// Вычислим длину пути к каталогу выгрузки. Ограничение файловой системы - 260 символов
		// Вычитаем из них сам каталог выгрузки и:
		// * 140 символов на имена формализованных документов
		// * если выбран вариант со служебными документами - 20 символов на каталог "Служебные документы\";
		// * если выбран вариант с архивацией - 3 символа на каталог "ВП/"
		СвободнаяДлинаПутиВыгрузки = 260 - 140 - ?(ВариантАрхивацииДокументов > 1, 3, 0) - ?(ВариантЭкспортаДокументов = 2, 20, 0) - СтрДлина(КаталогЭкспортаЭД);
		
		// Если в итоге остается меньше 21 символов, то выводим сообщение об ошибке
		// Минимум 21 символ нужен для формирования усеченного имени каталога в виде ИМЯКАТ~1/
		// и имени документа в виде ИМЯДОК~1.РСШ
		// Меньшее количество символов не позволит сформирвоать понятные и читаемые имена
		Если СвободнаяДлинаПутиВыгрузки < 21 Тогда
			ОтправитьУведомлениеПользователю("Невозможно выгрузить в указанный каталог. Выберите каталог с менее длинным именем или уровнем вложенности");
			Возврат;
		КонецЕсли;
		
		Если ВариантАрхивацииДокументов = 3 И НЕ ВариантЭкспортаДокументов = 3 Тогда
			//Создаем общий архив, в него закидываем папки с доками
			ИмяАрхива = "AllDocuments_" + Формат(ТекущаяДата(), "ДФ=ггггММдд_ччммсс");
			НовыйZipАрхив = Новый ЗаписьZipФайла(КаталогЭкспортаЭД + "\" + ИмяАрхива + ".zip", "", "", МетодСжатияZIP.Сжатие, УровеньСжатияZIP.Максимальный, МетодШифрованияZIP.Zip20);
			//создаем временную папку для хранения архивных файлов
			ВременнаяПапкаДляХраненияАрхивныхФайлов = КаталогЭкспортаЭД + "\ВП";
			Файл_ВременнаяПапкаДляХраненияАрхивныхФайлов = Новый Файл(ВременнаяПапкаДляХраненияАрхивныхФайлов);
			Если НЕ Файл_ВременнаяПапкаДляХраненияАрхивныхФайлов.Существует() Тогда
				СоздатьКаталог(ВременнаяПапкаДляХраненияАрхивныхФайлов);
			КонецЕсли;
		КонецЕсли;
		
		// ТЗ документов для валидации (автотесты) 
		ТаблицаДокументовДляТестирования = Новый ТаблицаЗначений;
		ТаблицаДокументовДляТестирования.Колонки.Добавить("ID_Документа");
		ТаблицаДокументовДляТестирования.Колонки.Добавить("ПутьВыгрузки");
		
		Если НЕ ВариантЭкспортаДокументов = 3 Тогда
			//Бежим по выбранным документам
			Для Каждого ТекСтрока Из ДокументыДляЭкспорта Цикл
				//создаем папку документа
				ДокументПредставление = СокрЛП(СтрЗаменить(ТекСтрока.ДокументПредставление, ":", ""));
				ДокументПредставление = СтрЗаменить(ДокументПредставление, ")", "");
				ДокументПредставление = СтрЗаменить(ДокументПредставление, "(", "");
				ДокументПредставление = СтрЗаменить(ДокументПредставление, "[", "");
				ДокументПредставление = СтрЗаменить(ДокументПредставление, "[", "");
				ДокументПредставление = СтрЗаменить(ДокументПредставление, "`", "");
				ДокументПредставление = СтрЗаменить(ДокументПредставление, "$", "");
				ДокументПредставление = СтрЗаменить(ДокументПредставление, "!", "");
				ДокументПредставление = СтрЗаменить(ДокументПредставление, "@", "");
				ДокументПредставление = СтрЗаменить(ДокументПредставление, "#", "");
				ДокументПредставление = СтрЗаменить(ДокументПредставление, ";", "");
				ДокументПредставление = СтрЗаменить(ДокументПредставление, """", "");
				
				//Кроме того, убираем точку в конце (например, "г.")
				Если Прав(ДокументПредставление, 1) = "." Тогда
					ДокументПредставление = Лев(ДокументПредставление, СтрДлина(ДокументПредставление) - 1);
				КонецЕсли;
				
				// для автотестов
				Если СтруктураПараметровТестирования = Неопределено Тогда
					КаталогДокумента = КаталогЭкспортаЭД + "\" + ?(ВариантАрхивацииДокументов = 3, "ВП\", "") + ДокументПредставление;
				Иначе
					КаталогДокумента = КаталогЭкспортаЭД + ДокументПредставление;
				КонецЕсли;
				
				Файл_КаталогДокумента = Новый Файл(КаталогДокумента);
				
				Если НЕ Файл_КаталогДокумента.Существует() Тогда
					//Создаем каталог
					СоздатьКаталог(КаталогДокумента);
				Иначе
					// Учтем ситуацию когда есть документы с одинаковым именем
					СчетчикУникальности = 1;
					Пока Истина Цикл
						Файл_КаталогДокумента = Новый Файл(КаталогДокумента + "(" + Строка(СчетчикУникальности) + ")");
						Если Файл_КаталогДокумента.Существует() Тогда
							СчетчикУникальности = СчетчикУникальности+1;
						Иначе
							СоздатьКаталог(КаталогДокумента + "(" + Строка(СчетчикУникальности) + ")");
							КаталогДокумента = КаталогДокумента + "(" + Строка(СчетчикУникальности) + ")";
							ДокументПредставление = ДокументПредставление + "(" + Строка(СчетчикУникальности) + ")";
							Прервать;
						КонецЕсли;
						
					КонецЦикла;
					
				КонецЕсли;                       
				
				//для варианта 2 создаем архив для каждого документа
				Если ВариантАрхивацииДокументов = 2 Тогда
					//Создаем архив, доки в него закидываем
					НовыйZipАрхив = Новый ЗаписьZipФайла(КаталогДокумента + ".zip", "", "", МетодСжатияZIP.Сжатие, УровеньСжатияZIP.Максимальный, МетодШифрованияZIP.Zip20);
				КонецЕсли;
				
				//получаем все содержимое ЭД
				ПолнаяИфнормацияОДокументе = ExchangeService.GetFullDocumentInfo(Токен, Syn_ЯщикОрганизации, ТекСтрока.IDДокумента, );
				Syn_Документ = ПолнаяИфнормацияОДокументе.Document;
				
				Если ПолнаяИфнормацияОДокументе = Неопределено Тогда
					ОтправитьУведомлениеПользователю("Ошибка получения информации об ЭД");
					Возврат;
				КонецЕсли;
				Документ_ИмяФайла = ?(СтруктураПараметровТестирования = Неопределено, ПолнаяИфнормацияОДокументе.Document.FileName, Строка(Новый УникальныйИдентификатор()) + ".xml");
				Документ_ДвоичныеДанные = ExchangeService.GetDocumentContent(Токен, Syn_ЯщикОрганизации, Syn_Документ.Id);
				Если Документ_ДвоичныеДанные = Неопределено Тогда
					ОтправитьУведомлениеПользователю("Ошибка получения информации об ЭД");
					Возврат;
				КонецЕсли;
				
				//Сначала сохраняем файл на диск в папку документа
				СохранитьЭлектронныйДокументНаДиск(Документ_ДвоичныеДанные, Документ_ИмяФайла, КаталогДокумента);
				
				// заполняем ТЗ документов для валидации (автотесты)
				Если НЕ СтруктураПараметровТестирования = Неопределено Тогда
					НовСтр				= ТаблицаДокументовДляТестирования.Добавить();
					НовСтр.ID_Документа = Syn_Документ.Id;
					НовСтр.ПутьВыгрузки	= КаталогДокумента + "\" + Документ_ИмяФайла;
				КонецЕсли;
				
				//Бежим по его ЭЦП и сохраняем тоже
				Syn_Подписи = ПолнаяИфнормацияОДокументе.Signs;
				Для ы = 0 По Syn_Подписи.Sign.Количество() - 1 Цикл
					Подпись_ДвоичныеДанные = Syn_Подписи.Sign[ы].Raw;
					//Для формализованных	
					Если НЕ ПолнаяИфнормацияОДокументе.Document.DocumentType = "Untyped" Тогда
						ИмяФайлаПодписи = Лев(Документ_ИмяФайла,СтрДлина(Документ_ИмяФайла)-4);
						Подпись_ИмяФайла = ИмяФайлаПодписи+"SGN";
					Иначе
						Подпись_ИмяФайла = СтрЗаменить(Syn_Подписи.Sign[ы].Subject, """", "_");
					КонецЕсли;
					
					СохранитьЭЦПНаДиск(Подпись_ДвоичныеДанные, Подпись_ИмяФайла, КаталогДокумента);
				КонецЦикла;
				
				Если ВариантЭкспортаДокументов = 1 Тогда
					//Далее смотрим все служебные документы к этому документу
					Syn_СлужебныеДокументы = ПолнаяИфнормацияОДокументе.ServiceDocuments;
					Для ы = 0 По Syn_СлужебныеДокументы.ServiceDocument.Количество() - 1 Цикл
						Syn_СлужебныйДокумент = Syn_СлужебныеДокументы.ServiceDocument[ы];
						
						СлужебныйДокумент_ИмяФайла = Syn_СлужебныйДокумент.FileName;
						СлужебныйДокумент_ДвоичныеДанные = ?(Syn_СлужебныйДокумент.FileSize > 1000000, 
						ExchangeService.GetDocumentContent(Токен, Syn_ЯщикОрганизации, Syn_СлужебныйДокумент.Id),
						Syn_СлужебныйДокумент.Content); 
						Если СлужебныйДокумент_ДвоичныеДанные = Неопределено Тогда
							ОтправитьУведомлениеПользователю("Ошибка получения контента (содержимого) ЭД");
							Возврат;
						КонецЕсли;
						
						Подпись_ДвоичныеДанные = Syn_СлужебныйДокумент.SignRaw;
						
						
						ИмяФайлаПодписи = Лев(СлужебныйДокумент_ИмяФайла,СтрДлина(СлужебныйДокумент_ИмяФайла)-4);
						
						Подпись_ИмяФайла = ИмяФайлаПодписи+"SGN";
						
						//Сохраняем файл на диск
						Если  Лев(СлужебныйДокумент_ИмяФайла, 10) = "DP_ZAKTPRM" Или
							Лев(СлужебныйДокумент_ИмяФайла, 10) = "DP_PTORG12" Тогда
							СохранитьЭлектронныйДокументНаДиск(СлужебныйДокумент_ДвоичныеДанные, СлужебныйДокумент_ИмяФайла, КаталогДокумента);
							СохранитьЭЦПНаДиск(Подпись_ДвоичныеДанные, Подпись_ИмяФайла, КаталогДокумента);
						КонецЕсли;
						
						//Сохраняем файл на диск
					КонецЦикла;
					
				КонецЕсли;
				
				Если ВариантЭкспортаДокументов = 2 Тогда
					//Далее смотрим все служебные документы к этому документу
					Syn_СлужебныеДокументы = ПолнаяИфнормацияОДокументе.ServiceDocuments;
					Для ы = 0 По Syn_СлужебныеДокументы.ServiceDocument.Количество() - 1 Цикл
						Syn_СлужебныйДокумент = Syn_СлужебныеДокументы.ServiceDocument[ы];
						
						СлужебныйДокумент_ИмяФайла = Syn_СлужебныйДокумент.FileName;
						
						Если СтрДлина(КаталогЭкспортаЭД) + 2 * СтрДлина(СлужебныйДокумент_ИмяФайла) > 250 Тогда
							//	Сообщить("Путь к выбранному каталогу слишком длинный. Имена выгружаемых файлов будут обрезаны.");
							МаксимальнаяДлинаИмениДокумента = (250 - СтрДлина(КаталогЭкспортаЭД)) / 2;
							СлужебныйДокумент_ИмяФайла = Лев(СлужебныйДокумент_ИмяФайла, МаксимальнаяДлинаИмениДокумента - 1) + "~";
						КонецЕсли;
						
						СлужебныйДокумент_ДвоичныеДанные = ?(Syn_СлужебныйДокумент.FileSize > 1000000, 
						ExchangeService.GetDocumentContent(Токен, Syn_ЯщикОрганизации, Syn_СлужебныйДокумент.Id),
						Syn_СлужебныйДокумент.Content);
						Если СлужебныйДокумент_ДвоичныеДанные = Неопределено Тогда
							ОтправитьУведомлениеПользователю("Ошибка получения контента (содержимого) ЭД");
							Возврат;
						КонецЕсли;
						
						Подпись_ДвоичныеДанные = Syn_СлужебныйДокумент.SignRaw;
						
						
						ИмяФайлаПодписи = Лев(СлужебныйДокумент_ИмяФайла,СтрДлина(СлужебныйДокумент_ИмяФайла)-4);
						Подпись_ИмяФайла = ИмяФайлаПодписи+"SGN";
						
						//Сохраняем файл на диск
						Если Лев(СлужебныйДокумент_ИмяФайла, 10) = "DP_ZAKTPRM" Или
							Лев(СлужебныйДокумент_ИмяФайла, 10) = "DP_PTORG12" Тогда
							СохранитьЭлектронныйДокументНаДиск(СлужебныйДокумент_ДвоичныеДанные, СлужебныйДокумент_ИмяФайла, КаталогДокумента);
							СохранитьЭЦПНаДиск(Подпись_ДвоичныеДанные, Подпись_ИмяФайла, КаталогДокумента);
						Иначе
							ВрКаталог = Новый Файл(КаталогДокумента + "\Служебные документы");
							Если Не ВрКаталог.Существует() Тогда
								СоздатьКаталог(ВрКаталог.ПолноеИмя);
							КонецЕсли;
							СохранитьЭлектронныйДокументНаДиск(СлужебныйДокумент_ДвоичныеДанные, СлужебныйДокумент_ИмяФайла, КаталогДокумента + "\Служебные документы");
							СохранитьЭЦПНаДиск(Подпись_ДвоичныеДанные, Подпись_ИмяФайла, КаталогДокумента + "\Служебные документы");
						КонецЕсли;
						
						//Сохраняем файл на диск
					КонецЦикла;
				КонецЕсли;
				
				Если ВариантАрхивацииДокументов = 2 Тогда
					//Отдельный архив для каждого документа
					НовыйZipАрхив.Добавить(КаталогДокумента + "\*.*", РежимСохраненияПутейZIP.СохранятьОтносительныеПути, РежимОбработкиПодкаталоговZIP.ОбрабатыватьРекурсивно);
					НовыйZipАрхив.Записать();
					УдалитьФайлы(КаталогДокумента);
				КонецЕсли;
			КонецЦикла;
			
			Если ВариантАрхивацииДокументов = 3 Тогда
				//Общий архив
				НовыйZipАрхив.Добавить(ВременнаяПапкаДляХраненияАрхивныхФайлов + "\*.*", РежимСохраненияПутейZIP.СохранятьОтносительныеПути, РежимОбработкиПодкаталоговZIP.ОбрабатыватьРекурсивно);//, РежимСохраненияПутейZIP.СохранятьОтносительныеПути, РежимОбработкиПодкаталоговZIP.ОбрабатыватьРекурсивно);
				НовыйZipАрхив.Записать();
				УдалитьФайлы(ВременнаяПапкаДляХраненияАрхивныхФайлов);
			КонецЕсли;
		// Для ИФНс		
		Иначе
			Для Каждого ТекЭлемент Из ДокументыДляЭкспорта Цикл
				ТекКонтент = ExchangeService.DownloadDocumentFlowArchive(Токен, Syn_ЯщикОрганизации, ТекЭлемент.ID_ЭкземпляраДокумента);
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
	
	ВыгрузкаЗавершена = Истина;
	
	Закрыть(ТаблицаДокументовДляТестирования);
	
КонецПроцедуры

Процедура ОбзорНажатие(Элемент)
	ДиалогВыбораКаталога = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.ВыборКаталога);
	ДиалогВыбораКаталога.Каталог = КаталогЭкспортаЭД;
	ДиалогВыбораКаталога.Заголовок = "Укажите каталог";
	Если ДиалогВыбораКаталога.Выбрать() Тогда
		КаталогЭкспортаЭД = ДиалогВыбораКаталога.Каталог;
	КонецЕсли;
КонецПроцедуры

Процедура ПриОткрытии()
	
	Если НЕ СтруктураПараметровТестирования = Неопределено Тогда
		ПодключитьОбработчикОжидания("АвтоматическийЭкспорт", 1);
	КонецЕсли;
	
	УстановитьЗаголовокОкна(ЭтаФорма, "Настройка экспорта");
	
	Если Не ЗначениеЗаполнено(ВариантЭкспортаДокументов) Тогда
		ВариантЭкспортаДокументов = 1;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ВариантАрхивацииДокументов) Тогда
		ВариантАрхивацииДокументов = 2;
	КонецЕсли;
	
КонецПроцедуры

Процедура ПередОткрытием(Отказ, СтандартнаяОбработка)
	
	Если СтруктураПараметровТестирования = Неопределено Тогда
		
		//Восстанавливаем настройки пользователя
		Попытка
			СтруктураНастроек = ВосстановитьЗначение("Syn_НастройкиЭкспортаДокументов");
			Если ТипЗнч(СтруктураНастроек) = Тип("Структура") Тогда
				КаталогЭкспортаЭД = СтруктураНастроек.КаталогЭкспортаЭД;
				ВариантЭкспортаДокументов = СтруктураНастроек.ВариантЭкспортаДокументов;
				ВариантАрхивацииДокументов = СтруктураНастроек.ВариантАрхивацииДокументов;
			КонецЕсли;
		Исключение
			
		КонецПопытки;
	Иначе
		// для автотестов
		КаталогЭкспортаЭД 			= КаталогВременныхФайлов();
		ВариантЭкспортаДокументов 	= 1;
		ВариантАрхивацииДокументов	= 1;
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриЗакрытии()
	
	//: ДокументыДляЭкспорта = Новый Массив;
	
	Если НЕ ВыгрузкаЗавершена Тогда
		Телеметрия.ОтправитьАналитику(
			СобытияТелеметрии.Экспорт.Отмена,
			ЭтаФорма, , ,
			ДокументыДляЭкспорта.Количество()
		);
	КонецЕсли;
	
	//Записываем установленные свойства
	СтруктураНастроек = Новый Структура;
	СтруктураНастроек.Вставить("КаталогЭкспортаЭД", КаталогЭкспортаЭД);
	СтруктураНастроек.Вставить("ВариантЭкспортаДокументов", ВариантЭкспортаДокументов);
	СтруктураНастроек.Вставить("ВариантАрхивацииДокументов", ВариантАрхивацииДокументов);
	
	СохранитьЗначение("Syn_НастройкиЭкспортаДокументов", СтруктураНастроек);
	
КонецПроцедуры

Процедура АвтоматическийЭкспорт() 
	
	ОтключитьОбработчикОжидания("АвтоматическийЭкспорт");
	
	КнопкаВыполнитьНажатие(ЭтаФорма.ЭлементыФормы.ОсновныеДействияФормы.Кнопки.ОсновныеДействияФормыВыполнить);
	
КонецПроцедуры


ИнициализироватьФорму();
