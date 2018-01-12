/*
 * Author: ACRE2Team
 * Updates the HUD display line in vehicles.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Unit <OBJECT>
 *
 * Return Value:
 * NONE
 *
 * Example:
 * [vehicle player, player] call acre_sys_intercom_fnc_vehicleInfoLine
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_vehicle", "_unit"];

private _intercomNames = _vehicle getVariable [QEGVAR(sys_intercom,intercomNames), []];
private _infoLine = "";
{
    private _connectionStatus = [_vehicle, _unit, _forEachIndex, INTERCOM_STATIONSTATUS_CONNECTION] call EFUNC(sys_intercom,getStationConfiguration);
    private _isBroadcasting = ((_vehicle getVariable [QGVAR(broadcasting), [false, objNull]]) select _forEachIndex) params ["_isBroadcasting", "_broadcastingUnit"];
    private _isVoiceActive = [_vehicle, _unit, _forEachIndex, INTERCOM_STATIONSTATUS_VOICEACTIVATION] call EFUNC(sys_intercom,getStationConfiguration);

    private _color = "";
    private _textStatus = "";
    private _displayName = _x select 2;
    switch (_connectionStatus) do {
        case INTERCOM_DISCONNECTED: {
            _color = "#737373";
        };
        case INTERCOM_RX_ONLY: {
            _color = "#ffffff";
            _textStatus = format ["<t font='PuristaBold' color='%1' size='0.6'>(R) </t>", _color];
        };
        case INTERCOM_TX_ONLY: {
            _color = "#ffffff";
            if (_isBroadcasting && {_broadcastingUnit == acre_player}) then {
                _textStatus = format ["<t font='PuristaBold' color='%1' size='0.6'>(B) </t>", _color];
            } else {
                if (_isVoiceActive) then {
                    _textStatus = format ["<t font='PuristaBold' color='%1' size='0.6'>(T) </t>", _color];
                } else {
                    if (_unit getVariable [QGVAR(intercomPTT), false]) then {
                        _textStatus = format ["<t font='PuristaBold' color='%1' size='0.6'>(P) </t>", _color];
                    } else {
                        _textStatus = format ["<t font='PuristaBold' color='#737373' size='0.6'>(P) </t>"];
                    };
                };
            };
        };
        case INTERCOM_RX_AND_TX: {
            _color = "#ffffff";
            if (_isBroadcasting && {_broadcastingUnit == acre_player}) then {
                _textStatus = format ["<t font='PuristaBold' color='%1' size='0.6'>(R/B) </t>", _color];
            } else {
                if (_isVoiceActive) then {
                    _textStatus = format ["<t font='PuristaBold' color='%1' size='0.6'>(R/T) </t>", _color];
                } else {
                    if (_unit getVariable [QGVAR(intercomPTT), false]) then {
                        _textStatus = format ["<t font='PuristaBold' color='%1' size='0.6'>(R/P) </t>", _color];
                    } else {
                        _textStatus = format ["<t font='PuristaBold' color='%1' size='0.6'>(R/</t>", _color];
                        _textStatus = _textStatus + format ["<t font='PuristaBold' color='#737373' size='0.6'>P/</t>"];
                        _textStatus = _textStatus + format ["<t font='PuristaBold' color='%1' size='0.6'>) </t>", _color];
                    };
                };
            };
        };
    };

    private _voiceActivation = [_vehicle, _unit, _forEachIndex, INTERCOM_STATIONSTATUS_VOICEACTIVATION] call EFUNC(sys_intercom,getStationConfiguration);

    _infoLine = _infoLine + format ["<t font='PuristaBold' color='%1' size='0.8'>%2 </t>", _color, _displayName] + _textStatus;
} forEach _intercomNames;

_infoLine = _infoLine + format ["<t font='PuristaBold' color='#ffffff' size='0.8'>| </t>"];

{
    if ([_x, _unit] call EFUNC(sys_rack,isRackAccessible) || [_x, _unit] call EFUNC(sys_rack,isRackHearable)) then {
        private _rackClassName = _x;
        private _config = ConfigFile >> "CfgVehicles" >> _rackClassName;
        private _displayName = [_rackClassName, "getState", "name"] call EFUNC(sys_data,dataEvent);
        private _mountedRadio = [_rackClassName] call EFUNC(sys_rack,getMountedRadio);
        private _color = "#737373";
        private _textStatus = "";
        if (_mountedRadio in ACRE_ACCESSIBLE_RACK_RADIOS || {_mountedRadio in ACRE_HEARABLE_RACK_RADIOS}) then {
            _color = "#ffffff";
            _textStatus = "(R/T)";
            if ([_x, _unit] call EFUNC(sys_rack,isRackHearable)) then {

                private _connectionStatus = ["", _vehicle, _unit, _x] call FUNC(getRackRxTxCapabilities);
                switch (_connectionStatus) do {
                    case RACK_NO_MONITOR: {
                        _textStatus = "";
                    };
                    case RACK_RX_ONLY: {
                        _textStatus = "(R)";
                    };
                    case RACK_TX_ONLY: {
                        _textStatus = "(T)";
                    };
                    case RACK_RX_AND_TX: {
                        _textStatus = "(R/T)";
                    };
                };
            };
        };

        _infoLine = _infoLine + format ["<t font='PuristaBold' color='%1' size='0.8'>%2 </t>", _color, _displayName];
        _infoLine = _infoLine + format ["<t font='PuristaBold' color='%1' size='0.6'>%2 </t>", _color, _textStatus];
    };
} forEach ([_vehicle] call EFUNC(sys_rack,getVehicleRacks));

[_infoLine] call EFUNC(sys_gui,updateVehInfo);
