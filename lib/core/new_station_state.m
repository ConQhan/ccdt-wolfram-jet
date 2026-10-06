function st = new_station_state(name)
%NEW_STATION_STATE core/station.py :: StationState dataclass portu.
%   Bir hesap istasyonundaki tam akis durumu. mass_flow ve
%   angular_momentum, bir bilesenden digerine tasinan iki temel
%   korunan buyuklukdur.
%
%   Istasyon numaralandirmasi (Aungier Bolum 5, s.73, kitapla birebir):
%     -1 : IGV giris kenari (varsa)
%      0 : Impeller goz (eye) kosulu
%      1 : Impeller bicak girisi
%      2 : Impeller cikisi (tip)
%      3 : Vaneli difuzor girisi
%      4 : Difuzor cikisi
%      5 : Crossover / volut girisi
%      6 : Crossover / volut cikisi
%      7 : Return channel vane / exit cone cikisi
%      8 : Return channel cikisi

if nargin < 1
    name = '';
end

st.name = name;
st.total = new_fluid_state();
st.static = new_fluid_state();
st.vel = new_velocity_triangle();
st.geom = new_geometry();
st.mass_flow = 0.0;
st.angular_momentum = 0.0;
st.loss_total_pressure = 0.0;

end
