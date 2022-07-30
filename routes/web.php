<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/


Route::get('/', 'MainController@index')->name('main-page');
Route::get('autosuggestion', 'MainController@autoSuggestion')->name('autosuggestion');
Route::post('transaction', 'MainController@transaction')->name('transaction');
Route::get('output', 'MainController@output')->name('output');
Route::get('/transaction/edit/{id}', 'MainController@showDataTransactionShare')->name('showDataTransactionShare');

Route::view('/new', 'Pages.transaction_share_new');

//--------Transaction Bank----------
Route::post('saveTransactionBank', 'MainController@saveTransactionBank')->name('saveTransactionBank');

//--------Account----------
Route::post('createAccount', 'MainController@createAccount')->name('createAccount');
Route::post('saveAccount', 'MainController@saveAccount')->name('saveAccount');

//--------Transaction Share----------
Route::put('/transaction/edit/{id}', 'MainController@updateTransactionShare')->name('updateTransactionBank');
Route::post('saveTransactionShare', 'MainController@saveTransactionShare')->name('saveTransactionShare');

//--------Company----------
Route::post('createCompany', 'MainController@createCompany')->name('createCompany');
Route::post('saveCompany', 'MainController@saveCompany')->name('saveCompany');
