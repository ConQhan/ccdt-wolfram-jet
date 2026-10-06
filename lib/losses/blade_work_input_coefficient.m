function I_B = blade_work_input_coefficient(sigma, lam, phi2, beta2, U1, Cu1, U2)
%BLADE_WORK_INPUT_COEFFICIENT losses/impeller_losses.py portu.
%   Eq. (4-5): I_B = sigma*(1 - lam*phi2*cot(beta2)) - U1*Cu1/U2^2

if nargin < 5 || isempty(U1); U1 = 0.0; end
if nargin < 6 || isempty(Cu1); Cu1 = 0.0; end
if nargin < 7 || isempty(U2); U2 = 1.0; end

I_B = sigma * (1.0 - lam * phi2 / tan(beta2)) - U1 * Cu1 / U2^2;

end
