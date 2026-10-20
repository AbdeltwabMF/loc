// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Loc';

  @override
  String get appIconSemanticLabel => 'Ícone do Loc';

  @override
  String get newReminderTooltip => 'Novo lembrete';

  @override
  String get linkOpenError => 'Não foi possível abrir esse link.';

  @override
  String get licenseGpl3 => 'Licenciado sob a GPL-3.0';

  @override
  String get remindersTitle => 'Lembretes';

  @override
  String get moreOptionsTooltip => 'Mais opções';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get sourceCode => 'Código-fonte';

  @override
  String get privacyPolicy => 'Política de privacidade';

  @override
  String get aboutApp => 'Sobre';

  @override
  String get searchRemindersHint => 'Pesquisar lembretes';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterPinned => 'Fixados';

  @override
  String get filterActive => 'Ativos';

  @override
  String get filterTriggered => 'No alcance';

  @override
  String get filterPaused => 'Pausados';

  @override
  String get pinnedReminderSemanticLabel => 'Lembrete fixado';

  @override
  String alertDistanceMeters(int meters) {
    return 'Distância do alerta: $meters m';
  }

  @override
  String get reminderStatusTriggered => 'No alcance';

  @override
  String get trackingEnabledSemanticLabel => 'Rastreamento ativado';

  @override
  String get trackingPausedSemanticLabel => 'Rastreamento pausado';

  @override
  String get unpinReminder => 'Desafixar lembrete';

  @override
  String get pinReminder => 'Fixar lembrete';

  @override
  String get deleteReminder => 'Excluir lembrete';

  @override
  String get deleteReminderConfirmationTitle => 'Excluir este lembrete?';

  @override
  String get actionCannotBeUndone => 'Esta ação não pode ser desfeita.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String distanceMetersAway(int meters) {
    return 'A $meters m de distância';
  }

  @override
  String distanceKilometersAway(String kilometers) {
    return 'A $kilometers km de distância';
  }

  @override
  String get directionNorthShort => 'N';

  @override
  String get directionNorthEastShort => 'NE';

  @override
  String get directionEastShort => 'L';

  @override
  String get directionSouthEastShort => 'SE';

  @override
  String get directionSouthShort => 'S';

  @override
  String get directionSouthWestShort => 'SO';

  @override
  String get directionWestShort => 'O';

  @override
  String get directionNorthWestShort => 'NO';

  @override
  String destinationBearingDegrees(int degrees) {
    return 'Direção do destino: $degrees graus';
  }

  @override
  String get destinationStraightAhead => 'O destino está logo à frente';

  @override
  String destinationDegreesRight(int degrees) {
    return 'O destino está $degrees graus à direita';
  }

  @override
  String destinationDegreesLeft(int degrees) {
    return 'O destino está $degrees graus à esquerda';
  }

  @override
  String get noMatchingReminders => 'Nenhum lembrete correspondente';

  @override
  String get emptyRemindersMessage => 'Sua próxima parada começa aqui';

  @override
  String get genericError => 'Algo deu errado. Tente novamente.';

  @override
  String get droppedPinLabel => 'Alfinete inserido';

  @override
  String placeWithCoordinates(String place, String coordinates) {
    return '$place · $coordinates';
  }

  @override
  String get trackingAccessHeading => 'Acesso ao rastreamento';

  @override
  String get arrivalNotifications => 'Notificações de chegada';

  @override
  String get arrivalNotificationsEnabledDescription =>
      'Avise-me quando eu chegar';

  @override
  String get allowNotificationsPrompt => 'Toque para permitir notificações';

  @override
  String get screenOffTracking => 'Rastreamento com a tela desligada';

  @override
  String get checkingLocationStatus => 'Verificando o status da localização…';

  @override
  String get screenOffTrackingDescription =>
      'Continuar rastreando com a tela desligada';

  @override
  String get locationServiceRequired =>
      'Requer que a localização esteja ativada';

  @override
  String get allowLocationAllTheTimeTitle =>
      'Permitir acesso à localização o tempo todo';

  @override
  String get allowLocationAllTheTimeInstructions =>
      'Toque aqui, abra Permissões > Localização e selecione “Permitir o tempo todo”';

  @override
  String get batteryOptimizationOnTitle =>
      'A otimização da bateria está ativada';

  @override
  String get disableBatteryRestrictionsDescription =>
      'Desative as restrições de bateria para garantir o rastreamento com a tela desligada';

  @override
  String get appearanceHeading => 'Aparência';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get fontGoogleSans => 'Google Sans';

  @override
  String get fontBalooBhaijaan2 => 'Baloo Bhaijaan 2';

  @override
  String get useSystemFont => 'Usar fonte do sistema';

  @override
  String get systemFontDescription => 'Usar a fonte padrão do dispositivo';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Padrão do sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languagePortuguese => 'Português (Brasil)';

  @override
  String get newReminderTitle => 'Novo lembrete';

  @override
  String get editReminderTitle => 'Editar lembrete';

  @override
  String get destinationLabel => 'Destino';

  @override
  String get alertLabel => 'Alerta';

  @override
  String get notifyWithinLabel => 'Avise-me quando eu estiver a';

  @override
  String get alertStyleSound => 'Som';

  @override
  String get alertStyleVibrate => 'Vibração';

  @override
  String get alertStyleAlarm => 'Alarme';

  @override
  String get alertStyleSoundDescription =>
      'Reproduz o som de uma notificação uma vez';

  @override
  String get alertStyleVibrateDescription => 'Vibra sem reproduzir som';

  @override
  String get alertStyleAlarmDescription =>
      'Repete usando o volume do alarme até ser dispensado';

  @override
  String get retrievingLocationAddress => 'Buscando o endereço do local…';

  @override
  String get savingLabel => 'Salvando…';

  @override
  String get createReminderAction => 'Criar lembrete';

  @override
  String get saveChangesAction => 'Salvar alterações';

  @override
  String get otherMapAction => 'Outro mapa';

  @override
  String get hideCoordinatesAction => 'Ocultar coordenadas';

  @override
  String get coordinatesShortLabel => 'Coordenadas';

  @override
  String get reminderNameLabel => 'Nome do lembrete';

  @override
  String get reminderNameHint => 'Estação central';

  @override
  String get clearReminderNameTooltip => 'Limpar nome do lembrete';

  @override
  String get reminderNameRequiredError => 'Digite um nome para o lembrete';

  @override
  String get changeAction => 'Alterar';

  @override
  String get chooseOnMapAction => 'Escolher no mapa';

  @override
  String get latitudeLabel => 'Latitude';

  @override
  String get longitudeLabel => 'Longitude';

  @override
  String coordinateRangeError(String minimum, String maximum) {
    return 'De $minimum a $maximum';
  }

  @override
  String distanceMetersShort(int meters) {
    return '$meters m';
  }

  @override
  String distanceKilometersShort(String kilometers) {
    return '$kilometers km';
  }

  @override
  String distanceMetersSemantic(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count metros',
      one: '1 metro',
    );
    return '$_temp0';
  }

  @override
  String distanceKilometersSemantic(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quilômetros',
      one: '1 quilômetro',
    );
    return '$_temp0';
  }

  @override
  String get chooseInAnotherMapTitle => 'Escolher em outro mapa';

  @override
  String get externalMapStepChooseDestination => 'Escolha o destino';

  @override
  String get externalMapStepTapShare => 'Toque em Compartilhar';

  @override
  String get externalMapStepSelectLoc => 'Selecione o Loc';

  @override
  String get dontShowAgain => 'Não mostrar novamente';

  @override
  String get openMapAction => 'Abrir mapa';

  @override
  String get noCompatibleMapAppError =>
      'Nenhum aplicativo de mapas compatível está instalado';

  @override
  String get destinationRequiredError =>
      'Escolha um destino ou insira coordenadas válidas';

  @override
  String get reminderNotSavedTitle => 'O lembrete não foi salvo';

  @override
  String get reminderNotSavedMessage =>
      'Seus dados ainda estão aqui. Verifique sua conexão e tente novamente.';

  @override
  String get keepEditingAction => 'Continuar editando';

  @override
  String get chooseDestinationTitle => 'Escolher destino';

  @override
  String get mapPickerInstructions => 'Mova e amplie o mapa sob o alfinete';

  @override
  String get mapTilesUnavailableMessage =>
      'Os blocos do mapa não estão disponíveis. Você ainda pode escolher um local.';

  @override
  String get openStreetMapAttribution => '© Colaboradores do OpenStreetMap';

  @override
  String get myLocationTooltip => 'Minha localização';

  @override
  String get findingAddress => 'Buscando endereço…';

  @override
  String get useThisLocationAction => 'Usar este local';

  @override
  String get allowLocationAccessTitle => 'Permitir acesso à localização';

  @override
  String get mapLocationPermissionMessage =>
      'O Loc precisa da sua permissão para centralizar o mapa na sua localização.';

  @override
  String get allowAction => 'Permitir';

  @override
  String get enableLocationInAndroidSettingsMessage =>
      'Ative a permissão de localização para o Loc nas configurações do Android.';

  @override
  String get openSettingsAction => 'Abrir configurações';

  @override
  String get notNowAction => 'Agora não';

  @override
  String get locationUnknownError =>
      'Não foi possível determinar sua localização. Tente novamente.';

  @override
  String get permissionSetupTitle => 'Configurar permissões';

  @override
  String get locationAccessNeededTitle => 'Restaurar acesso';

  @override
  String get permissionSetupDescription =>
      'O Loc precisa das seguintes permissões';

  @override
  String get locationRecoveryDescription =>
      'Algumas permissões necessárias ou configurações do dispositivo estão desativadas';

  @override
  String get requiredPermissionsHeading => 'Obrigatório';

  @override
  String get locationPermissionTitle => 'Localização';

  @override
  String get locationPermissionDescription =>
      'Para detectar quando você chega ao destino';

  @override
  String get turnOnAction => 'Ativar';

  @override
  String get optionalPermissionsHeading => 'Opcional';

  @override
  String get notificationsPermissionTitle => 'Notificações';

  @override
  String get notificationsPermissionDescription =>
      'Para avisar quando você chegar';

  @override
  String get backgroundLocationSettingsInstruction =>
      'Em Permissões > Localização, selecione “Permitir o tempo todo”';

  @override
  String get screenOffTrackingPermissionDescription =>
      'Para manter os lembretes ativos quando a tela estiver desligada';

  @override
  String get batteryAccessTitle => 'Acesso à bateria';

  @override
  String get batteryAccessDescription =>
      'Para manter os lembretes ativos funcionando de forma confiável';

  @override
  String get continueAction => 'Continuar';

  @override
  String get resumeRemindersAction => 'Retomar lembretes';

  @override
  String get optionalPermissionsSettingsNote =>
      'Você pode alterar as permissões opcionais mais tarde nas Configurações';

  @override
  String get arrivalAlarmsChannelName => 'Alarmes de chegada';

  @override
  String get arrivalAlarmsChannelDescription =>
      'Alarmes repetidos para destinos que precisam acordar você.';

  @override
  String get arrivalVibrationsChannelName => 'Vibrações de chegada';

  @override
  String get arrivalVibrationsChannelDescription =>
      'Alertas de vibração silenciosos ao chegar a um destino ativo.';

  @override
  String get arrivalRemindersChannelName => 'Lembretes de chegada';

  @override
  String get arrivalRemindersChannelDescription =>
      'Alertas breves ao chegar a um destino ativo.';

  @override
  String get backgroundTrackingNotificationTitle =>
      'O Loc está acompanhando seu trajeto';

  @override
  String get backgroundTrackingNotificationBody =>
      'Os lembretes de chegada ativos estão sendo verificados.';

  @override
  String get arrivalNotificationTitle => 'Você chegou';

  @override
  String get locationAccessBlockedError =>
      'O acesso à localização está bloqueado. Ative-o nas configurações do Android.';

  @override
  String get locationAccessNotGrantedError =>
      'O acesso à localização não foi concedido.';

  @override
  String get deviceLocationDisabledError =>
      'Ative a localização do dispositivo para rastrear os lembretes.';

  @override
  String get backgroundLocationRequiredError =>
      'Permita o acesso à localização o tempo todo para que os lembretes funcionem com a tela desligada.';

  @override
  String get activeRemindersLocationRequiredError =>
      'O acesso à localização é necessário para lembretes ativos.';

  @override
  String get enableActiveRemindersLocationError =>
      'Ative o acesso à localização para os lembretes ativos.';

  @override
  String get mapInvalidResponseError =>
      'O OpenStreetMap retornou uma resposta inválida. Tente novamente mais tarde.';

  @override
  String get mapConnectivityError =>
      'Não foi possível acessar o OpenStreetMap. Verifique sua conexão com a internet e permita o acesso do Loc em qualquer VPN, firewall ou aplicativo de economia de dados.';

  @override
  String mapHttpStatusError(int statusCode) {
    return 'O serviço de mapas retornou o código $statusCode. Tente novamente mais tarde.';
  }
}
