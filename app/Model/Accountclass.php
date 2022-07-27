<?php

namespace App\Model;

use Illuminate\Database\Eloquent\Model;

class Accountclass extends Model
{
    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'accountclass';
    protected $fillable = ['AccountClass'];
    public $timestamps = false; 

}
