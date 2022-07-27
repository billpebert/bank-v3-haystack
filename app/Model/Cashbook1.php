<?php

namespace App\Model;

use Illuminate\Database\Eloquent\Model;

class Cashbook1 extends Model
{
    protected $table = 'cashbook1';
    protected $fillable = ['Amount','creditFK','DebitFK','Numbercredited','Numberdebited','tstamp','fx','Date'];
    public $timestamps = false; 
}
