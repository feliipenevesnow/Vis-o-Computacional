clc;

clear all;

close all;

pkg load image;


% Dados de entrada
mrows = 960;
ncols = 1280;
ISO = 800;
Bits = 16;
gain = ISO / 100;
blackLevel = 4800;
exposureTime = 1/34; % segundos
a1 = 0.00036494025950395686;
a2 = 8.8666518209275022e-08;
a3 = 1.4911493946260918e-05;
cx = 697.57412520205469; % em pixels
cy = 483.3379020042467; % em pixels
k0 = -0.00011488197737851787;
k1 = 1.183167572859751e-06;
k2 = -1.171867123703797e-08;
k3 = 3.3530562168475598e-11;
k4 = -4.1718260305381848e-14;
k5 = 1.8823938615703626e-17;

% Carregar a imagem
image_path = 'IMG_0080_5.tif';
raw_image = imread(image_path);

% Normalização dos valores dos pixels
normalized_image = double(raw_image) / (2^Bits - 1);
pBL = blackLevel / (2^Bits - 1);

% Cálculo da imagem corrigida do efeito vignetting
[x, y] = meshgrid(1:ncols, 1:mrows);
r = sqrt((x - cx).^2 + (y - cy).^2);
k = 1 + k0 * r + k1 * r.^2 + k2 * r.^3 + k3 * r.^4 + k4 * r.^5 + k5 * r.^6;
vignetting_correction = 1 ./ k;
corrected_image_vignetting = normalized_image .* vignetting_correction;

% Cálculo da imagem de radiância
radiance_image = corrected_image_vignetting .* (a1 / gain) .* ((normalized_image - pBL) ./ (exposureTime + a2 * y - a3 * exposureTime * y));

% Exibir as imagens
figure;
subplot(1, 3, 1); imshow(normalized_image); title('Imagem Original');
subplot(1, 3, 2); imshow(corrected_image_vignetting); title('Correção de Vignetting');
subplot(1, 3, 3); imshow(radiance_image); title('Imagem de Radiância');

% Salvar a imagem de radiância em formato .tif
output_path = 'imagem_radiancia.tif';
imwrite(radiance_image, output_path);


