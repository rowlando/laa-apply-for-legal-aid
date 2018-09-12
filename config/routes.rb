Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/docs'
  mount Rswag::Api::Engine => '/docs'

  resources :status, only: [:index]

  namespace 'v1' do
    resources :status, only: [:index]
    resources :applications, only: [:create, :show]
    resources :applicants
  end
end
