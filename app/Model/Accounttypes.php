<?php

namespace App\Model;

use Illuminate\Database\Eloquent\Model;

class Accounttypes extends Model
{
    protected $fillable = ['AccountTypesName', 'Window'];
    public $timestamps = false; 
}
