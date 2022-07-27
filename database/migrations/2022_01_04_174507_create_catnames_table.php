<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateCatnamesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('catnames', function (Blueprint $table) {
            $table->decimal('CatNo', 5, 1)->unique()->default('0.0');
            $table->primary('CatNo');
            $table->string('CatDesc',80);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('catnames');
    }
}
