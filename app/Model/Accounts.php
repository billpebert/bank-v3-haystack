<?php

namespace App\Model;

use Illuminate\Database\Eloquent\Model;

class Accounts extends Model
{
    protected $fillable = ['AccountName', 'AccountFK'];
    public $timestamps = false; 
}
