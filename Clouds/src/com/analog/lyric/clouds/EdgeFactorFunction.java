package com.analog.lyric.clouds;

import com.analog.lyric.dimple.factorfunctions.core.FactorFunction;
import com.analog.lyric.dimple.model.values.Value;

public class EdgeFactorFunction extends FactorFunction 
{

	@Override
	public double evalEnergy(Value[] args)
	{
		int index = 0;
		double [][] top = (double[][])args[index++].getObject();
		double [][] bottom = (double[][])args[index++].getObject();
		double [] distribution = args[index++].getDoubleArray();
		double hdelta = args[index++].getDouble();
		boolean leftRight = args[index++].getBoolean();
		boolean useDist = args[index++].getBoolean();
		
		double diff = 0;
		double topLength = top[0].length;
		
		if (leftRight)
		{
			for (int i = 0; i < topLength; i++)
			{
				double tmp = top[1][i] - bottom[0][i];			
				diff = tmp*tmp;
			}
		}
		else
		{
			for (int i = 0; i < topLength; i++)
			{
				double tmp = top[3][i] - bottom[2][i];			
				diff = tmp*tmp;
			}
		}		
		diff = Math.sqrt(diff);
		int ind = (int)(diff/hdelta);
		if (ind > distribution.length-1)
			ind = distribution.length-1;
		
		if (useDist)
			return -Math.log(distribution[ind]);
		else
			return diff;
	}

}
