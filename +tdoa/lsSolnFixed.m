function [x,x_full] = lsSolnFixed(x_tdoa,rho,C,x_init,a,tol,epsilon,max_num_iterations,force_full_calc,plot_progress,ref_idx)
% [x,x_full] = lsSolnFixed(x_tdoa,rho,C,x_init,a,tol,epsilon,max_num_iterations,...
%                               force_full_calc, plot_progress,ref_idx)
%
% Computes the least square solution for TDOA processing.
%
% Utilized the utils.constraints package to accept equality constraints (a)
% with tolerance (tol).
%
% Inputs:
%   
%   x_tdoa              Sensor positions [m]
%   rho                 Range-Difference Measurements [m]
%   C                   Range-Difference Error Covariance Matrix [m^2]
%   x_init              Initial source position estimate [m]
%   a                   Array of equality constraint function handles
%   tol                 Tolerance for equality constraints
%   epsilon             Desired estimate resolution [m]
%   max_num_iterations  Maximum number of iterations to perform
%   force_full_calc     Boolean flag to force all iterations (up to
%                       max_num_iterations) to be computed, regardless
%                       of convergence (DEFAULT = False)
%   plot_progress       Boolean flag dictacting whether to plot
%                       intermediate solutions as they are derived 
%                       (DEFAULT = False).
%   ref_idx             Scalar index of reference sensor, or nDim x nPair
%                       matrix of sensor pairings           
% 
% Outputs:
%   x               Estimated source position
%   x_full          Iteration-by-iteration estimated source positions
%
% Nicholas O'Donoughue
% 14 November 2021

% Parse inputs
if nargin < 11 || ~exist('ref_idx','var')
    ref_idx = [];
end

if nargin < 10 || ~exist('plot_progress','var')
    plot_progress = false;
end

if nargin < 9 || ~exist('force_full_calc','var')
    force_full_calc = false;
end

if nargin < 8 || ~exist('max_num_iterations','var')
    max_num_iterations = [];
end

if nargin < 7 || ~exist('epsilon','var')
    epsilon = [];
end

% Initialize measurement error and Jacobian function handles
y = @(x) rho- tdoa.measurement(x_tdoa, x, ref_idx);
J = @(x) tdoa.jacobian(x_tdoa, x, ref_idx);

% Resample covariance matrix
n_sensor = size(x_tdoa, 2);
[test_idx_vec, ref_idx_vec] = utils.parseReferenceSensor(ref_idx, n_sensor);
C_tilde = utils.resampleCovMtx(C, test_idx_vec, ref_idx_vec);

% Call the generic Least Square solver
[x,x_full] = utils.constraints.lsSolnFixed(y,J,C_tilde,x_init,a,tol,...
    epsilon,max_num_iterations,force_full_calc,plot_progress);